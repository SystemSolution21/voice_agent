# Voice Assistant Agent

A real-time, voice-to-voice AI pipeline featuring an intelligent assistant agent. Built with LangChain/LangGraph agents, AssemblyAI for speech-to-text, and Cartesia for text-to-speech.

## 🎯 Overview

This project implements a complete voice-to-voice conversational AI system with a streaming pipeline architecture. Users can speak naturally to an AI assistant that understands speech, processes requests using LangChain agents with tool-calling capabilities, and responds with natural-sounding synthesized speech.

### Key Features

- **Real-time Voice Interaction**: Seamless voice-to-voice conversation with minimal latency
- **Streaming Pipeline**: Efficient event-driven architecture processing audio, transcription, agent responses, and speech synthesis concurrently
- **LangChain/LangGraph Agents**: Intelligent agents with tool-calling capabilities and conversation memory
- **Multiple Implementations**: Both Python (FastAPI) and TypeScript (Hono) backend implementations
- **Modern Web UI**: Interactive Svelte-based interface with real-time visualization of the processing pipeline
- **Production-Ready**: WebSocket-based communication, proper error handling, and modular architecture

## 🏗️ Architecture

The system uses a **streaming pipeline architecture** where data flows through multiple transformation stages:

```text
Audio Input → STT → Agent → TTS → Audio Output
```

### Pipeline Stages

1. **Audio Capture** (Web UI)
   - Captures microphone input using Web Audio API
   - Resamples to 16kHz PCM format
   - Streams audio chunks via WebSocket

2. **Speech-to-Text (STT)** - AssemblyAI
   - Real-time streaming transcription
   - Emits partial transcripts (`stt_chunk`) and final transcripts (`stt_output`)
   - Turn-based formatting with punctuation and capitalization

3. **Agent Processing** - LangChain/LangGraph
   - Receives final transcripts
   - Processes with Claude Haiku 4.5 model
   - Executes tool calls when needed
   - Maintains conversation context with memory checkpointer
   - Streams response tokens in real-time

4. **Text-to-Speech (TTS)** - Cartesia Sonic
   - Converts agent responses to natural speech
   - Streams audio chunks as they're generated
   - 24kHz PCM output for high-quality audio

5. **Audio Playback** (Web UI)
   - Receives audio chunks via WebSocket
   - Schedules seamless playback using Web Audio API
   - Handles buffering and timing

### Event-Driven Design

The pipeline uses typed events for communication between stages:

- `user_input`: Audio data from microphone
- `stt_chunk`: Partial transcription
- `stt_output`: Final transcription
- `agent_chunk`: Streaming agent response text
- `agent_end`: Agent response complete
- `tool_call`: Agent invoking a tool
- `tool_result`: Tool execution result
- `tts_chunk`: Audio data for playback

## 📁 Project Structure

```text
voice-assistant-agent/
├── voice-assistant-agent/
│   ├── backend/              # Python implementation (FastAPI)
│   │   ├── src/
│   │   │   ├── main.py              # FastAPI server & pipeline
│   │   │   ├── assemblyai_stt.py   # AssemblyAI STT integration
│   │   │   ├── cartesia_tts.py     # Cartesia TTS integration
│   │   │   ├── elevenlabs_tts.py   # ElevenLabs TTS (alternative)
│   │   │   ├── events.py           # Event type definitions
│   │   │   ├── cartesia_prompts.py # TTS-optimized prompts
│   │   │   └── utils.py            # Utility functions
│   │   ├── pyproject.toml          # Python dependencies
│   │   └── uv.lock                 # Locked dependencies
│   │
│   ├── frontend/             # TypeScript implementation (Hono)
│   │   ├── src/
│   │   │   ├── index.ts            # Hono server & pipeline
│   │   │   ├── types.ts            # TypeScript type definitions
│   │   │   ├── utils.ts            # Utility functions
│   │   │   ├── assemblyai/         # AssemblyAI integration
│   │   │   ├── cartesia/           # Cartesia integration
│   │   │   └── elevenlabs/         # ElevenLabs integration
│   │   └── package.json            # Node.js dependencies
│   │
│   └── web/                  # Svelte web interface
│       ├── src/
│       │   ├── App.svelte          # Main application component
│       │   ├── main.ts             # Application entry point
│       │   ├── lib/
│       │   │   ├── components/     # UI components
│       │   │   │   ├── Header.svelte
│       │   │   │   ├── Controls.svelte
│       │   │   │   ├── PipelineCard.svelte
│       │   │   │   ├── ActivityFeed.svelte
│       │   │   │   ├── Console.svelte
│       │   │   │   └── LatencyWaterfall.svelte
│       │   │   ├── stores/         # Svelte stores for state
│       │   │   ├── audio/          # Audio capture/playback
│       │   │   ├── websocket.ts    # WebSocket client
│       │   │   └── types.ts        # TypeScript types
│       │   └── app.css             # Global styles
│       └── package.json            # Web dependencies
│
├── Makefile                  # Build and development commands
├── LICENSE.txt               # MIT License
└── README.md                 # This file
```

## 🚀 Getting Started

### Prerequisites

- **Python 3.13+** (for backend implementation)
- **Node.js 18+** and **pnpm** (for frontend/web)
- **uv** (Python package manager) - [Install uv](https://github.com/astral-sh/uv)
- API Keys:
  - [Anthropic API Key](https://console.anthropic.com/) (for Claude)
  - [AssemblyAI API Key](https://www.assemblyai.com/) (for STT)
  - [Cartesia API Key](https://cartesia.ai/) (for TTS)

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd voice-assistant-agent
   ```

2. **Set up environment variables**

   ```bash
   cp .env.example .env
   ```

   Edit `.env` and add your API keys:

   ```env
   ANTHROPIC_API_KEY=sk-...
   ASSEMBLYAI_API_KEY=...
   CARTESIA_API_KEY=...
   ```

3. **Install all dependencies**

   ```bash
   make bootstrap
   ```

   This installs:
   - Python dependencies (backend)
   - Node.js dependencies (frontend)
   - Node.js dependencies (web UI)

### Running the Application

#### Option 1: Python Backend (Recommended)

```bash
make dev-py
```

This command:

- Starts the web build watcher (rebuilds on changes)
- Starts the FastAPI server on `http://localhost:8000`

#### Option 2: TypeScript Backend

```bash
make dev-ts
```

This command:

- Starts the web build watcher (rebuilds on changes)
- Starts the Hono server on `http://localhost:8000`

#### Production Build

For production deployment without hot-reload:

```bash
# Build web assets once
make build-web

# Start Python backend
make start-py

# OR start TypeScript backend
make start-ts
```

### Using the Application

1. Open your browser to `http://localhost:8000`
2. Click the **Start** button to begin a voice session
3. Grant microphone permissions when prompted
4. Speak naturally to the assistant
5. The assistant will respond with voice
6. Monitor the pipeline visualization and activity feed in real-time
7. Click **Stop** to end the session

## 🛠️ Development

### Available Make Commands

```bash
# Installation
make bootstrap          # Install all dependencies (web + frontend + backend)
make install-web        # Install web UI dependencies
make install-ts         # Install TypeScript backend dependencies
make install-py         # Install Python backend dependencies

# Development (with hot-reload)
make dev-py            # Run Python backend with web watcher
make dev-ts            # Run TypeScript backend with web watcher
make dev-web           # Run web build watcher only

# Production
make build-web         # Build web UI for production
make start-py          # Start Python backend (requires built web)
make start-ts          # Start TypeScript backend (requires built web)

# Type Checking
make check-web         # Type check web UI
make check-ts          # Type check TypeScript backend
make check             # Type check both web and TypeScript

# Utilities
make clean             # Remove all build artifacts and dependencies
```

### Project Structure Details

#### Backend (Python)

The Python backend uses **FastAPI** with async/await for high-performance WebSocket handling:

- **`main.py`**: Core server with three streaming pipeline stages
  - `_stt_stream()`: Audio → STT events
  - `_agent_stream()`: STT events → Agent events
  - `_tts_stream()`: Agent events → TTS audio
- **`assemblyai_stt.py`**: AssemblyAI WebSocket client for streaming transcription
- **`cartesia_tts.py`**: Cartesia WebSocket client for streaming TTS
- **`events.py`**: Dataclass definitions for all event types
- **`utils.py`**: Helper functions for async stream merging

#### Frontend (TypeScript)

The TypeScript frontend uses **Hono** (lightweight web framework) with similar architecture:

- **`index.ts`**: Core server with streaming pipeline stages
- **`assemblyai/`**: AssemblyAI integration with TypeScript types
- **`cartesia/`**: Cartesia integration with TypeScript types
- **`types.ts`**: Complete TypeScript type definitions for all events
- **`utils.ts`**: Async iterator utilities

#### Web UI (Svelte)

Modern reactive UI built with **Svelte 5** and **TailwindCSS**:

- **Components**:
  - `Header.svelte`: Application title and branding
  - `Controls.svelte`: Start/Stop buttons and session controls
  - `PipelineCard.svelte`: Visual representation of the pipeline stages
  - `ActivityFeed.svelte`: Real-time feed of events (transcripts, tool calls, etc.)
  - `Console.svelte`: Debug logs and system messages
  - `LatencyWaterfall.svelte`: Latency visualization for each pipeline stage

- **State Management**: Svelte stores for reactive state
  - Session state (connected, recording, status)
  - Current turn tracking
  - Activity feed
  - Latency statistics
  - Console logs

- **Audio Processing**:
  - `audio/capture.ts`: Microphone capture with AudioWorklet for resampling
  - `audio/playback.ts`: Seamless audio playback with Web Audio API

## 🔧 Customization

### Changing the Agent Behavior

The default agent is a sandwich shop assistant. To customize:

**Python (`voice-assistant-agent/backend/src/main.py`):**

```python
# Define your tools
def your_custom_tool(param: str) -> str:
    """Your tool description."""
    return f"Result: {param}"

# Update system prompt
system_prompt = """
Your custom instructions here.

${CARTESIA_TTS_SYSTEM_PROMPT}
"""

# Create agent with your tools
agent = create_agent(
    model="anthropic:claude-haiku-4-5",  # or other models
    tools=[your_custom_tool],
    system_prompt=system_prompt,
    checkpointer=InMemorySaver(),
)
```

**TypeScript (`voice-assistant-agent/frontend/src/index.ts`):**

```typescript
// Define your tools
const yourCustomTool = tool(
    async ({ param }) => {
        return `Result: ${param}`;
    },
    {
        name: "your_custom_tool",
        description: "Your tool description.",
        schema: z.object({
            param: z.string(),
        }),
    }
);

// Update system prompt and create agent
const agent = createAgent({
    model: "claude-haiku-4-5",
    tools: [yourCustomTool],
    checkpointer: new MemorySaver(),
    systemPrompt: systemPrompt,
});
```

### Changing the AI Model

The project supports multiple LLM providers through LangChain:

**Available Models:**

- `anthropic:claude-haiku-4-5` (default, fast and cost-effective)
- `anthropic:claude-sonnet-4-5` (more capable)
- `openai:gpt-4o` (requires OpenAI API key)
- `google:gemini-2.0-flash-exp` (requires Google API key)

Update the `model` parameter in the agent configuration.

### Changing TTS Provider

The project includes both Cartesia and ElevenLabs integrations:

**To use ElevenLabs instead of Cartesia:**

1. Add your ElevenLabs API key to `.env`:

   ```env
   ELEVENLABS_API_KEY=...
   ```

2. Update the imports and TTS initialization in `main.py` or `index.ts`:

   ```python
   from elevenlabs_tts import ElevenLabsTTS

   # In _tts_stream function:
   tts = ElevenLabsTTS()
   ```

### Audio Configuration

**STT Configuration** (in AssemblyAI initialization):

- `sample_rate`: Audio sample rate (default: 16000 Hz)
- `format_turns`: Enable turn-based formatting (default: True)

**TTS Configuration** (in Cartesia initialization):

- `voice_id`: Cartesia voice ID (default: friendly female voice)
- `model_id`: TTS model (default: "sonic-3")
- `sample_rate`: Output sample rate (default: 24000 Hz)
- `encoding`: Audio encoding (default: "pcm_s16le")

## 📊 Monitoring and Debugging

### Web UI Features

1. **Pipeline Visualization**: Shows the current state of each pipeline stage
2. **Activity Feed**: Real-time display of:
   - User speech transcriptions
   - Agent responses
   - Tool calls and results
3. **Console Logs**: System messages and debug information
4. **Latency Waterfall**: Visual breakdown of latency for each stage

### Server Logs

Both Python and TypeScript backends log important events:

- WebSocket connections/disconnections
- STT events (partial and final transcripts)
- Agent processing
- Tool executions
- TTS generation
- Errors and warnings

## 🔒 Security Considerations

- **API Keys**: Never commit API keys to version control. Use `.env` files (gitignored)
- **CORS**: The default configuration allows all origins (`*`). Restrict this in production:

  ```python
  # Python
  app.add_middleware(
      CORSMiddleware,
      allow_origins=["https://yourdomain.com"],
      ...
  )
  ```

- **WebSocket Authentication**: Consider adding authentication for production deployments
- **Rate Limiting**: Implement rate limiting to prevent abuse
- **Input Validation**: The current implementation trusts all input; add validation for production

## 🧪 Testing

### Manual Testing

1. Start the application
2. Test basic conversation flow
3. Test tool calling (e.g., "I'd like a turkey sandwich with lettuce")
4. Test error handling (disconnect during conversation)
5. Monitor latency in the waterfall visualization

### Automated Testing

The project structure supports adding tests:

**Python:**

```bash
cd voice-assistant-agent/backend
# Add pytest to dev dependencies
uv add --dev pytest pytest-asyncio
# Create tests/ directory and add test files
```

**TypeScript:**

```bash
cd voice-assistant-agent/frontend
# Add testing framework
pnpm add -D vitest @vitest/ui
# Create tests/ directory and add test files
```

## 🚀 Deployment

### Environment Variables for Production

Create a `.env` file with production API keys:

```env
# Required
ANTHROPIC_API_KEY=sk-ant-...
ASSEMBLYAI_API_KEY=...
CARTESIA_API_KEY=...

# Optional
ELEVENLABS_API_KEY=...
OPENAI_API_KEY=...
GOOGLE_API_KEY=...

# Server Configuration
PORT=8000
```

### Docker Deployment (Example)

**Python Backend Dockerfile:**

```dockerfile
FROM python:3.13-slim

WORKDIR /app

# Install uv
RUN pip install uv

# Copy backend files
COPY voice-assistant-agent/backend /app/backend
COPY voice-assistant-agent/web/dist /app/web/dist

WORKDIR /app/backend

# Install dependencies
RUN uv sync --no-dev

# Expose port
EXPOSE 8000

# Run server
CMD ["uv", "run", "src/main.py"]
```

**Build and run:**

```bash
# Build web assets first
make build-web

# Build Docker image
docker build -t voice-assistant-agent .

# Run container
docker run -p 8000:8000 --env-file .env voice-assistant-agent
```

### Cloud Deployment Options

- **Heroku**: Deploy with Procfile
- **Railway**: Direct deployment from Git
- **Render**: Web service deployment
- **AWS/GCP/Azure**: Container deployment with ECS/Cloud Run/Container Apps
- **Vercel/Netlify**: For static web UI (requires separate backend)

## 🤝 Contributing

Contributions are welcome! Here's how to contribute:

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly**
5. **Commit your changes**: `git commit -m 'Add amazing feature'`
6. **Push to the branch**: `git push origin feature/amazing-feature`
7. **Open a Pull Request**

### Development Guidelines

- Follow existing code style and conventions
- Add comments for complex logic
- Update documentation for new features
- Test both Python and TypeScript implementations if applicable
- Ensure type safety (Python type hints, TypeScript types)

## 📝 Technical Details

### WebSocket Protocol

The client-server communication uses a simple WebSocket protocol:

**Client → Server:**

- Binary messages: PCM audio chunks (Int16Array, 16kHz, mono)

**Server → Client:**

- JSON messages: Event objects with `type` discriminator

Example event:

```json
{
  "type": "stt_output",
  "transcript": "I'd like a turkey sandwich",
  "ts": 1703001234567
}
```

### Audio Format Specifications

**Input Audio (Microphone → STT):**

- Format: PCM signed 16-bit little-endian
- Sample Rate: 16,000 Hz
- Channels: 1 (mono)
- Encoding: Linear PCM

**Output Audio (TTS → Playback):**

- Format: PCM signed 16-bit little-endian
- Sample Rate: 24,000 Hz
- Channels: 1 (mono)
- Encoding: Linear PCM
- Transport: Base64-encoded in JSON

### Pipeline Performance

Typical latency breakdown (measured from user speech to audio playback):

1. **Audio Capture**: ~100ms (buffering)
2. **STT Processing**: ~200-500ms (AssemblyAI)
3. **Agent Processing**: ~500-1500ms (depends on model and complexity)
4. **TTS Generation**: ~200-400ms (Cartesia streaming)
5. **Audio Playback**: ~50ms (buffering)

**Total**: ~1-2.5 seconds for a complete turn

Optimizations:

- Streaming at every stage reduces perceived latency
- Partial transcripts provide immediate feedback
- Agent response streaming starts before full generation
- TTS audio plays as soon as first chunks arrive

## 🐛 Troubleshooting

### Common Issues

#### **1. "Web build not found" error**

```bash
# Solution: Build the web UI first
make build-web
```

#### **2. WebSocket connection fails**

- Check that the server is running on port 8000
- Verify no firewall blocking WebSocket connections
- Check browser console for CORS errors

#### **3. No audio playback**

- Ensure browser has audio permissions
- Check browser console for Web Audio API errors
- Verify TTS API key is valid
- Check that audio chunks are being received (Console logs)

#### **4. Microphone not working**

- Grant microphone permissions in browser
- Check browser console for getUserMedia errors
- Verify microphone is not in use by another application
- Try HTTPS (some browsers require secure context)

#### **5. Agent not responding**

- Verify Anthropic API key is valid
- Check server logs for errors
- Ensure STT is producing transcripts (check Activity Feed)
- Verify network connectivity to Anthropic API

#### **6. High latency**

- Check network connection quality
- Monitor server logs for slow API responses
- Consider using a faster model (e.g., claude-haiku instead of sonnet)
- Check the Latency Waterfall to identify bottlenecks

### Debug Mode

Enable verbose logging:

**Python:**

```python
# In main.py, add logging configuration
import logging
logging.basicConfig(level=logging.DEBUG)
```

**TypeScript:**

```typescript
// Add console.log statements in pipeline stages
console.log('Event:', event);
```

## 📚 Resources

### Documentation

- [LangChain Documentation](https://python.langchain.com/)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [AssemblyAI Streaming API](https://www.assemblyai.com/docs/api-reference/streaming)
- [Cartesia API Documentation](https://docs.cartesia.ai/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Svelte Documentation](https://svelte.dev/)

### Related Projects

- [LangChain Voice Assistant Examples](https://github.com/langchain-ai/langchain)
- [AssemblyAI Examples](https://github.com/AssemblyAI/assemblyai-python-sdk)
- [Cartesia Examples](https://github.com/cartesia-ai)

## 📄 License

This project is licensed under the MIT License - see the [LICENSE.txt](LICENSE.txt) file for details.

## 🙏 Acknowledgments

- **LangChain/LangGraph**: For the excellent agent framework
- **AssemblyAI**: For high-quality streaming speech-to-text
- **Cartesia**: For natural-sounding text-to-speech
- **Anthropic**: For Claude AI models
- **FastAPI**: For the modern Python web framework
- **Svelte**: For the reactive UI framework

## 📧 Support

For questions, issues, or feature requests:

- Open an issue on GitHub
- Check existing issues for solutions
- Review the troubleshooting section above

---
