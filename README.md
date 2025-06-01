# 🤖 Unified AI Client

> **The Ultimate Multi-LLM Chat Platform**  
> One interface. Four AI providers. Zero complexity.

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)
![License](https://img.shields.io/badge/license-MIT-green.svg)
![Docker](https://img.shields.io/badge/docker-ready-blue.svg)

## ✨ Features

- 🤖 **Multi-AI Support**: OpenAI, Claude, Gemini, DeepSeek
- 🚀 **One-Command Setup**: Deploy in under 5 minutes
- 💬 **Clean Interface**: Intuitive chat experience
- 🔄 **Real-time Switching**: Change providers instantly
- 🐳 **Docker Ready**: Containerized deployment
- 📱 **Responsive Design**: Works on all devices

## 🚀 Quick Start

### One-Command Deployment

```bash
# Clone the repository
git clone https://github.com/yourusername/unified-ai-client.git
cd unified-ai-client

# Deploy everything
./deploy.sh
```

That's it! 🎉

### Manual Setup (Alternative)

```bash
# 1. Copy environment file
cp .env.example .env

# 2. Add your API keys to .env
nano .env

# 3. Start with Docker
docker compose up --build -d

# 4. Open browser
# Frontend: http://localhost:3000
# Backend: http://localhost:8000
```

## 🔑 API Keys

Get your API keys from:

| Provider | Sign Up | Documentation |
|----------|---------|---------------|
| **OpenAI** | [platform.openai.com](https://platform.openai.com/api-keys) | [Docs](https://platform.openai.com/docs) |
| **Claude** | [console.anthropic.com](https://console.anthropic.com/) | [Docs](https://docs.anthropic.com) |
| **Gemini** | [ai.google.dev](https://ai.google.dev/) | [Docs](https://ai.google.dev/docs) |
| **DeepSeek** | [platform.deepseek.com](https://platform.deepseek.com/) | [Docs](https://platform.deepseek.com/api-docs) |

## 📁 Project Structure

```
unified-ai-client/
├── backend/
│   ├── app.py              # Complete backend (500 lines)
│   ├── requirements.txt    # Python dependencies
│   └── Dockerfile          # Backend container
├── frontend/
│   └── index.html          # Complete frontend (single file)
├── docker-compose.yml      # Container orchestration
├── deploy.sh              # One-command deployment
├── .env.example           # Environment template
└── README.md              # This file
```

## 🎯 Available Models

### OpenAI
- gpt-4o, gpt-4o-mini, gpt-4-turbo
- gpt-3.5-turbo, o1-preview, o1-mini

### Claude
- claude-3-5-sonnet-20241022, claude-3-5-haiku-20241022
- claude-3-opus-20240229, claude-3-sonnet-20240229

### Gemini
- gemini-1.5-pro, gemini-1.5-flash, gemini-1.5-flash-8b
- gemini-1.0-pro, gemini-pro, gemini-pro-vision

### DeepSeek
- deepseek-chat, deepseek-reasoner
- deepseek-coder, deepseek-v2.5

## 🛠️ Commands

```bash
# Start application
docker compose up -d

# View logs
docker compose logs -f

# Stop application
docker compose down

# Restart services
docker compose restart

# Clean rebuild
docker compose down && docker compose up --build -d

# Health check
curl http://localhost:8000/health
```

## 🌐 Access Points

- **🌐 Frontend**: http://localhost:3000
- **🔧 Backend API**: http://localhost:8000
- **📖 API Documentation**: http://localhost:8000/docs
- **❤️ Health Check**: http://localhost:8000/health

## 🔧 Configuration

### Environment Variables (.env)

```bash
# Required: API Keys
OPENAI_API_KEY=sk-proj-your-key-here
CLAUDE_API_KEY=sk-ant-your-key-here
GEMINI_API_KEY=your-key-here
DEEPSEEK_API_KEY=your-key-here

# Optional: Custom endpoints (rarely needed)
# OPENAI_BASE_URL=https://api.openai.com/v1
# CLAUDE_BASE_URL=https://api.anthropic.com/v1
```

### Chat Parameters

- **Temperature**: 0.0-2.0 (creativity level)
- **Max Tokens**: 1-4096 (response length)
- **Provider Switching**: Real-time
- **Model Selection**: Per-provider

## 🔍 Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| White screen | Check browser console, verify Docker containers |
| Backend errors | Check API keys in .env file |
| Port conflicts | `docker compose down` then restart |
| CORS errors | Verify backend is running on port 8000 |

### Debug Commands

```bash
# Check container status
docker compose ps

# View backend logs
docker compose logs backend

# View frontend logs
docker compose logs frontend

# Test backend health
curl http://localhost:8000/health

# Check API keys (without revealing them)
grep "_API_KEY=" .env | head -c 20
```

## 🏗️ Development

### Local Development

```bash
# Backend (Python 3.11+)
cd backend
pip install -r requirements.txt
python app.py

# Frontend (any HTTP server)
cd frontend
python -m http.server 3000
```

### Adding New Features

The application is designed for easy customization:

- **Backend**: Modify `backend/app.py`
- **Frontend**: Modify `frontend/index.html`
- **Styling**: Edit CSS in the `<style>` section
- **New Providers**: Add to the LLMClients class

## 📈 Performance

- **Startup time**: < 30 seconds
- **Response time**: 2-10 seconds (depends on AI provider)
- **Memory usage**: < 512MB total
- **Concurrent users**: 50+ (with proper scaling)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenAI](https://openai.com) for GPT models
- [Anthropic](https://anthropic.com) for Claude
- [Google](https://ai.google.dev) for Gemini
- [DeepSeek](https://deepseek.com) for DeepSeek models

---

**Built with ❤️ for the AI community**

[⭐ Star this repo](https://github.com/yourusername/unified-ai-client) | [🐛 Report Bug](https://github.com/yourusername/unified-ai-client/issues) | [💡 Request Feature](https://github.com/yourusername/unified-ai-client/issues)
