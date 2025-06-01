#!/usr/bin/env python3
"""
Unified AI Client - Complete Backend
Single file with all LLM providers
"""

import os
import json
import asyncio
import logging
from datetime import datetime
from typing import Dict, List, Optional
from enum import Enum
from contextlib import asynccontextmanager

import aiohttp
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import uvicorn

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# =============================================================================
# MODELS
# =============================================================================

class Provider(str, Enum):
    OPENAI = "openai"
    CLAUDE = "claude"
    GEMINI = "gemini"
    DEEPSEEK = "deepseek"

class Message(BaseModel):
    role: str
    content: str

class ChatRequest(BaseModel):
    provider: Provider
    model: str
    messages: List[Message]
    temperature: float = 0.7

class ChatResponse(BaseModel):
    success: bool
    response: Optional[str] = None
    error: Optional[str] = None

# =============================================================================
# LLM CLIENTS
# =============================================================================

class LLMClients:
    def __init__(self):
        self.session = None
        self.models = {
            Provider.OPENAI: ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo", "o1-preview", "o1-mini"],
            Provider.CLAUDE: ["claude-3-5-sonnet-20241022", "claude-3-5-haiku-20241022", "claude-3-opus-20240229", "claude-3-sonnet-20240229", "claude-3-haiku-20240307"],
            Provider.GEMINI: ["gemini-1.5-pro", "gemini-1.5-flash", "gemini-1.5-flash-8b", "gemini-1.0-pro", "gemini-pro", "gemini-pro-vision"],
            Provider.DEEPSEEK: ["deepseek-chat", "deepseek-reasoner", "deepseek-coder", "deepseek-v2.5"]
        }
    
    async def init(self):
        self.session = aiohttp.ClientSession()
        logger.info("LLM clients initialized")
    
    async def cleanup(self):
        if self.session:
            await self.session.close()
            logger.info("LLM clients cleaned up")
    
    async def chat(self, provider: Provider, model: str, messages: List[Message], temperature: float) -> str:
        if provider == Provider.OPENAI:
            return await self._openai_chat(model, messages, temperature)
        elif provider == Provider.CLAUDE:
            return await self._claude_chat(model, messages, temperature)
        elif provider == Provider.GEMINI:
            return await self._gemini_chat(model, messages, temperature)
        elif provider == Provider.DEEPSEEK:
            return await self._deepseek_chat(model, messages, temperature)
        else:
            raise ValueError(f"Unsupported provider: {provider}")
    
    async def _openai_chat(self, model: str, messages: List[Message], temperature: float) -> str:
        api_key = os.getenv("OPENAI_API_KEY")
        if not api_key:
            raise ValueError("OpenAI API key not configured")
        
        headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
        payload = {
            "model": model,
            "messages": [{"role": m.role, "content": m.content} for m in messages],
            "temperature": temperature,
            "max_tokens": 2048
        }
        
        async with self.session.post("https://api.openai.com/v1/chat/completions", 
                                   headers=headers, json=payload) as resp:
            if resp.status != 200:
                error_text = await resp.text()
                raise Exception(f"OpenAI API error: {resp.status} - {error_text}")
            data = await resp.json()
            return data["choices"][0]["message"]["content"]
    
    async def _claude_chat(self, model: str, messages: List[Message], temperature: float) -> str:
        api_key = os.getenv("CLAUDE_API_KEY")
        if not api_key:
            raise ValueError("Claude API key not configured")
        
        headers = {"x-api-key": api_key, "Content-Type": "application/json", "anthropic-version": "2023-06-01"}
        claude_messages = [{"role": m.role, "content": m.content} for m in messages if m.role != "system"]
        
        payload = {
            "model": model,
            "messages": claude_messages,
            "max_tokens": 2048,
            "temperature": temperature
        }
        
        async with self.session.post("https://api.anthropic.com/v1/messages", 
                                   headers=headers, json=payload) as resp:
            if resp.status != 200:
                error_text = await resp.text()
                raise Exception(f"Claude API error: {resp.status} - {error_text}")
            data = await resp.json()
            return data["content"][0]["text"]
    
    async def _gemini_chat(self, model: str, messages: List[Message], temperature: float) -> str:
        api_key = os.getenv("GEMINI_API_KEY")
        if not api_key:
            raise ValueError("Gemini API key not configured")
        
        contents = []
        for m in messages:
            role = "user" if m.role in ["user", "system"] else "model"
            contents.append({"role": role, "parts": [{"text": m.content}]})
        
        payload = {
            "contents": contents,
            "generationConfig": {"temperature": temperature, "maxOutputTokens": 2048}
        }
        
        url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
        async with self.session.post(url, json=payload) as resp:
            if resp.status != 200:
                error_text = await resp.text()
                raise Exception(f"Gemini API error: {resp.status} - {error_text}")
            data = await resp.json()
            return data["candidates"][0]["content"]["parts"][0]["text"]
    
    async def _deepseek_chat(self, model: str, messages: List[Message], temperature: float) -> str:
        api_key = os.getenv("DEEPSEEK_API_KEY")
        if not api_key:
            raise ValueError("DeepSeek API key not configured")
        
        headers = {"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"}
        payload = {
            "model": model,
            "messages": [{"role": m.role, "content": m.content} for m in messages],
            "temperature": temperature,
            "max_tokens": 2048
        }
        
        async with self.session.post("https://api.deepseek.com/v1/chat/completions", 
                                   headers=headers, json=payload) as resp:
            if resp.status != 200:
                error_text = await resp.text()
                raise Exception(f"DeepSeek API error: {resp.status} - {error_text}")
            data = await resp.json()
            return data["choices"][0]["message"]["content"]

# =============================================================================
# FASTAPI APPLICATION
# =============================================================================

clients = LLMClients()

@asynccontextmanager
async def lifespan(app: FastAPI):
    await clients.init()
    yield
    await clients.cleanup()

app = FastAPI(
    title="Unified AI Client API",
    description="Multi-LLM API with OpenAI, Claude, Gemini, and DeepSeek",
    version="1.0.0",
    lifespan=lifespan
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure this properly in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health")
async def health():
    return {"status": "healthy", "timestamp": datetime.utcnow(), "version": "1.0.0"}

@app.get("/models")
async def get_models():
    return {"models": clients.models}

@app.post("/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        logger.info(f"Chat request: {request.provider} - {request.model}")
        response = await clients.chat(request.provider, request.model, request.messages, request.temperature)
        logger.info("Chat response generated successfully")
        return ChatResponse(success=True, response=response)
    except Exception as e:
        logger.error(f"Chat request failed: {e}")
        return ChatResponse(success=False, error=str(e))

@app.get("/")
async def root():
    return {"message": "Unified AI Client API", "docs": "/docs"}

if __name__ == "__main__":
    print("🚀 Starting Unified AI Backend")
    print("📊 API Documentation: http://localhost:8000/docs")
    print("❤️ Health Check: http://localhost:8000/health")
    uvicorn.run(app, host="0.0.0.0", port=8000, log_level="info")
