# ICTorch - Senior Secondary ICT Learning Platform

An adaptive AI-powered learning platform for Hong Kong HKDSE ICT students, combining a **Retrieval-Augmented Generation (RAG)** backend with a **Flutter** mobile app. The system delivers personalized study notes, quizzes, and an AI tutor — all grounded in curated ICT curriculum materials.

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Features](#features)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Backend Setup](#backend-setup)
  - [Cloud API Mode (Default)](#cloud-api-mode-default)
  - [Local Models with HuggingFace](#local-models-with-huggingface)
- [Flutter App Setup](#flutter-app-setup)
- [Deployment](#deployment)
- [API Reference](#api-reference)
- [Database Schema](#database-schema)
- [License](#license)

---

## Architecture Overview

```
Flutter App (Dart)          FastAPI Backend (Python)
┌──────────────┐            ┌─────────────────────────┐
│  Provider     │  HTTP/S   │  main.py (API routes)    │
│  State Mgmt   │ ───────> │  rag_core.py (RAG engine)│
│  Supabase     │           │  ChromaDB (vectors)      │
│  Local Cache  │           │  LLM (DeepSeek/Local)    │
└──────────────┘            └─────────────────────────┘
                                      │
                            ┌─────────┴──────────┐
                            │  Supabase (Auth +   │
                            │  PostgreSQL sync)   │
                            └────────────────────┘
```

## Features

- **Adaptive difficulty** — content tailored to beginner (S2-4), intermediate (S4-6), and advanced (top HKDSE) levels
- **Three response modes** — conversational chat, structured study notes (JSON), and MCQ quizzes (JSON)
- **RAG-powered answers** — responses grounded in 100+ curated HKDSE ICT markdown documents
- **Progress tracking** — local persistence with optional cloud sync for Google-authenticated users
- **Offline-first** — SharedPreferences caching ensures the app works without a network
- **5 compulsory + 3 elective modules** covering the full HKDSE ICT syllabus

## Project Structure

```
ICTorch/
├── main.py                  # FastAPI server with all API endpoints
├── rag_core.py              # RAG engine (embeddings, vector store, LLM)
├── parsing.py               # PDF-to-markdown converter (LlamaParse)
├── requirements.txt         # Python dependencies
├── Dockerfile               # Backend container image
├── fly.toml                 # Fly.io deployment config
├── supabase_migration.sql   # Database schema (users, progress, quizzes)
│
├── data_markdown/           # 101 curated ICT curriculum documents
│   ├── learning_materials/  # Topic content by module
│   ├── assessment/          # Exercises (compulsory & elective)
│   └── assessment_answers/  # Answer keys
│
├── chroma_ict_db/           # Persistent ChromaDB vector store
│
└── ict_rag_app/             # Flutter mobile application
    ├── lib/
    │   ├── main.dart        # Entry point & Supabase init
    │   ├── models/          # Data models (UserProfile, Module, Topic, Quiz)
    │   ├── services/        # API, state management, persistence, sync
    │   ├── screens/         # 16 UI screens (dashboard, quiz, chat, etc.)
    │   ├── theme/           # Light, Dark, OLED themes
    │   └── widgets/         # Reusable UI components
    └── pubspec.yaml         # Flutter dependencies
```

---

## Prerequisites

### Backend
- **Python** 3.12+
- **pip** (Python package manager)
- **Git**

### Flutter App
- **Flutter SDK** 3.11+
- **Dart SDK** (bundled with Flutter)
- **Android Studio** or **Xcode** (for emulator/device builds)

### Optional Services
- **Supabase** project (for Google auth and cloud sync)
- **SiliconFlow API key** (for cloud-based Qwen3 embeddings — default mode)
- **DeepSeek API key** (for the LLM)

---

## Backend Setup

### Cloud API Mode (Default)

This is the default configuration using SiliconFlow for embeddings and DeepSeek for the LLM.

1. **Clone the repository**

   ```bash
   git clone https://github.com/<your-username>/ICTorch.git
   cd ICTorch
   ```

2. **Create a virtual environment**

   ```bash
   python -m venv venv
   source venv/bin/activate    # Linux/macOS
   venv\Scripts\activate       # Windows
   ```

3. **Install dependencies**

   ```bash
   pip install -r requirements.txt
   ```

4. **Set environment variables**

   ```bash
   export DEEPSEEK_API_KEY="your-deepseek-api-key"
   export SILICONFLOW_API_KEY="your-siliconflow-api-key"

   # Optional: Supabase (required only for auth/sync features)
   export SUPABASE_URL="https://your-project.supabase.co"
   export SUPABASE_SERVICE_ROLE_KEY="your-service-role-key"
   ```

5. **Run the server**

   ```bash
   python main.py
   # or
   uvicorn main:app --host 0.0.0.0 --port 8000
   ```

   On first launch, the vector database will be built from `data_markdown/` (takes a few minutes). Subsequent launches load the existing ChromaDB instantly.

6. **Verify** — visit `http://localhost:8000/health`, you should see `{"status": "ready"}`.

---

### Local Models with HuggingFace

You can run the entire RAG pipeline locally without any cloud API by using HuggingFace models for both embeddings and the LLM. This requires a GPU with sufficient VRAM.

#### Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| GPU VRAM | 8 GB | 16+ GB |
| RAM | 16 GB | 32 GB |
| Disk | 20 GB (for model weights) | 40 GB |
| GPU | NVIDIA (CUDA) or AMD (ROCm) | NVIDIA RTX 3060+ / RTX 4060+ |

#### Step 1: Install additional dependencies

```bash
pip install -r requirements.txt
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121
pip install transformers sentence-transformers accelerate
```

> For AMD GPUs, replace `cu121` with `rocm5.7` (or your ROCm version):
> ```bash
> pip install torch --index-url https://download.pytorch.org/whl/rocm5.7
> ```

#### Step 2: Replace the embedding model in `rag_core.py`

The file already contains a commented-out `LocalQwen3Embedding` class. To activate it:

1. **Uncomment the imports** at the top of `rag_core.py`:

   ```python
   import torch
   from transformers import AutoTokenizer, AutoModel
   ```

2. **Uncomment the `LocalQwen3Embedding` class** (lines 18-58 in the docstring).

3. **Replace the embedding model setting** — change:

   ```python
   Settings.embed_model = SiliconFlowEmbedding(api_key=siliconflow_key)
   ```

   to:

   ```python
   Settings.embed_model = LocalQwen3Embedding(model_name="Qwen/Qwen3-Embedding-4B")
   ```

   The model weights (~8 GB) will be downloaded automatically from HuggingFace on first run and cached in `~/.cache/huggingface/`.

#### Step 3: Replace the LLM with a local model

To run a local LLM instead of DeepSeek, install `llama-index-llms-huggingface`:

```bash
pip install llama-index-llms-huggingface
```

Then replace the LLM setting in `rag_core.py`:

```python
# Remove or comment out:
# from llama_index.llms.deepseek import DeepSeek
# Settings.llm = DeepSeek(model="deepseek-reasoner")

# Add:
from llama_index.llms.huggingface import HuggingFaceLLM

Settings.llm = HuggingFaceLLM(
    model_name="Qwen/Qwen2.5-7B-Instruct",   # or any HF model you prefer
    tokenizer_name="Qwen/Qwen2.5-7B-Instruct",
    device_map="auto",
    model_kwargs={"torch_dtype": torch.float16},
    generate_kwargs={"temperature": 0.7, "top_p": 0.9, "max_new_tokens": 1024},
)
```

**Recommended local LLM options** (by VRAM):

| Model | VRAM Required | Quality |
|-------|---------------|---------|
| `Qwen/Qwen2.5-3B-Instruct` | ~6 GB | Good for basic Q&A |
| `Qwen/Qwen2.5-7B-Instruct` | ~14 GB | Recommended balance |
| `mistralai/Mistral-7B-Instruct-v0.3` | ~14 GB | Strong general-purpose |
| `Qwen/Qwen2.5-14B-Instruct` | ~28 GB | Best quality |

#### Step 4: Rebuild the vector database

If you switch embedding models, you **must** delete the existing vector store and rebuild it:

```bash
rm -rf chroma_ict_db/
python main.py
```

The new embeddings will be generated locally using your GPU. This may take 5-15 minutes depending on hardware.

#### Step 5: Verify

```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{"question": "What is an IP address?", "user_level": "beginner", "response_type": "chat"}'
```

---

## Flutter App Setup

1. **Navigate to the app directory**

   ```bash
   cd ict_rag_app
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure the backend URL**

   Edit `lib/services/api_service.dart` and set the `baseUrl` to your backend address:

   ```dart
   static const String baseUrl = 'http://10.0.2.2:8000'; // Android emulator → localhost
   // static const String baseUrl = 'http://localhost:8000';  // iOS simulator / web
   // static const String baseUrl = 'https://your-domain.fly.dev'; // Production
   ```

4. **Configure Supabase** (optional, for Google Sign-In)

   Update the Supabase URL and anon key in `lib/main.dart`:

   ```dart
   await Supabase.initialize(
     url: 'https://your-project.supabase.co',
     anonKey: 'your-anon-key',
   );
   ```

5. **Run the app**

   ```bash
   flutter run
   ```

---

## Deployment

### Backend (Docker + Fly.io)

1. **Build the Docker image**

   ```bash
   docker build -t ictorch-backend .
   ```

2. **Test locally**

   ```bash
   docker run -p 8000:8000 \
     -e DEEPSEEK_API_KEY="your-key" \
     -e SILICONFLOW_API_KEY="your-key" \
     ictorch-backend
   ```

3. **Deploy to Fly.io**

   ```bash
   fly launch          # First time
   fly secrets set DEEPSEEK_API_KEY="your-key" SILICONFLOW_API_KEY="your-key"
   fly deploy           # Subsequent deploys
   ```

### Flutter App

```bash
flutter build apk --release    # Android
flutter build ios --release    # iOS (requires macOS + Xcode)
```

---

## API Reference

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/health` | Health check — returns `{"status": "ready"}` |
| `POST` | `/query` | RAG query (question, user_level, response_type) |
| `POST` | `/auth/callback` | Exchange OAuth code for session |
| `POST` | `/sync/progress` | Upsert completed topics for a user |
| `GET` | `/sync/progress/{user_id}` | Get user's completed topics |
| `POST` | `/sync/quiz` | Save a quiz attempt |
| `GET` | `/sync/quiz/{user_id}` | Get user's quiz history |
| `POST` | `/sync/user` | Create/update user profile |

### Example: Query the RAG system

```bash
curl -X POST http://localhost:8000/query \
  -H "Content-Type: application/json" \
  -d '{
    "question": "Explain the difference between LAN and WAN",
    "user_level": "beginner",
    "response_type": "notes"
  }'
```

---

## Database Schema

The Supabase PostgreSQL schema (see `supabase_migration.sql`) includes:

- **users** — user profiles (Google ID, name, email, year of study, DSE grade)
- **topic_progress** — per-user topic completion tracking
- **quiz_attempts** — full quiz history with JSONB answers

---

## Environment Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `DEEPSEEK_API_KEY` | Yes (cloud mode) | DeepSeek LLM API key |
| `SILICONFLOW_API_KEY` | Yes (cloud mode) | SiliconFlow embeddings API key |
| `SUPABASE_URL` | No | Supabase project URL (for auth/sync) |
| `SUPABASE_SERVICE_ROLE_KEY` | No | Supabase service role key |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | FastAPI, Uvicorn |
| RAG Pipeline | LlamaIndex, ChromaDB |
| Embeddings | Qwen3-Embedding-4B (SiliconFlow API or local HuggingFace) |
| LLM | DeepSeek (cloud) or Qwen2.5 / Mistral (local HuggingFace) |
| Frontend | Flutter (Dart) |
| State Management | Provider |
| Auth | Google Sign-In + Supabase Auth (PKCE) |
| Database | Supabase (PostgreSQL) |
| Deployment | Docker, Fly.io |

---

## License

This project is for educational purposes. All ICT curriculum materials are aligned with the Hong Kong HKDSE ICT syllabus.
