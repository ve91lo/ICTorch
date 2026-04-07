import os
import requests
from typing import Any
from llama_index.core import VectorStoreIndex, SimpleDirectoryReader, Settings, StorageContext, PromptTemplate
from llama_index.core.embeddings import BaseEmbedding
from llama_index.vector_stores.chroma import ChromaVectorStore
from llama_index.llms.deepseek import DeepSeek
import chromadb

"""
Qwen/Qwen3-Embedding-4B is chosen for this vector database, optimized for GPUs with =>8GB VRAM.
For local embedding model implementations using GPU(NVIDIA CUDA/AMD ROCm compatible):

    import torch
    from transformers import AutoTokenizer, AutoModel
    from sentence_transformers import SentenceTransformer

class LocalQwen3Embedding(BaseEmbedding):
    embed_dim: int = 2560
    _model: Any = None
    _tokenizer: Any = None

    def __init__(self, model_name: str = "Qwen/Qwen3-Embedding-4B", **kwargs: Any):
        super().__init__(**kwargs)
        self._tokenizer = AutoTokenizer.from_pretrained(model_name)
        self._model = AutoModel.from_pretrained(model_name, torch_dtype=torch.float16)
        if torch.cuda.is_available():
            self._model = self._model.to("cuda")
        self._model.eval()

    @classmethod
    def class_name(cls) -> str:
        return "LocalQwen3Embedding"

    def _encode(self, texts: list[str]) -> list[list[float]]:
        device = next(self._model.parameters()).device
        inputs = self._tokenizer(
            texts, padding=True, truncation=True, max_length=512, return_tensors="pt"
        ).to(device)
        with torch.no_grad():
            outputs = self._model(**inputs)
            embeddings = outputs.last_hidden_state[:, 0, :]  # CLS token
        return embeddings.cpu().float().tolist()

    def _get_query_embedding(self, query: str) -> list[float]:
        return self._encode([query])[0]

    def _get_text_embedding(self, text: str) -> list[float]:
        return self._encode([text])[0]

    def _get_text_embedding_batch(self, texts: list[str], **kwargs: Any) -> list[list[float]]:
        return self._encode(texts)

    async def _aget_query_embedding(self, query: str) -> list[float]:
        return self._get_query_embedding(query)

    async def _aget_text_embedding(self, text: str) -> list[float]:
        return self._get_text_embedding(text)

Usage:
    Settings.embed_model = LocalQwen3Embedding(model_name="Qwen/Qwen3-Embedding-4B")
"""

SILICONFLOW_API_URL = "https://api.siliconflow.cn/v1/embeddings"
SILICONFLOW_MODEL = "Qwen/Qwen3-Embedding-4B"

class SiliconFlowEmbedding(BaseEmbedding):
    embed_dim: int = 2560  # Qwen3-Embedding-4B dimension
    _api_key: str = ""

    def __init__(self, api_key: str, **kwargs: Any):
        super().__init__(**kwargs)
        self._api_key = api_key

    @classmethod
    def class_name(cls) -> str:
        return "SiliconFlowEmbedding"

    def _call_api(self, texts: list[str]) -> list[list[float]]:
        resp = requests.post(
            SILICONFLOW_API_URL,
            headers={
                "Authorization": f"Bearer {self._api_key}",
                "Content-Type": "application/json",
            },
            json={"model": SILICONFLOW_MODEL, "input": texts},
            timeout=60,
        )
        resp.raise_for_status()
        data = resp.json()
        return [item["embedding"] for item in sorted(data["data"], key=lambda x: x["index"])]

    def _get_query_embedding(self, query: str) -> list[float]:
        return self._call_api([query])[0]

    def _get_text_embedding(self, text: str) -> list[float]:
        return self._call_api([text])[0]

    def _get_text_embedding_batch(self, texts: list[str], **kwargs: Any) -> list[list[float]]:
        # SiliconFlow supports batch embedding in a single call
        return self._call_api(texts)

    async def _aget_query_embedding(self, query: str) -> list[float]:
        return self._get_query_embedding(query)

    async def _aget_text_embedding(self, text: str) -> list[float]:
        return self._get_text_embedding(text)

# ====================== SETTINGS ======================
os.environ["DEEPSEEK_API_KEY"] = os.getenv("DEEPSEEK_API_KEY", "sk-9fd4b3655dbb4de1ba1d984a71e1d96c")
siliconflow_key = os.getenv("SILICONFLOW_API_KEY", "")

Settings.llm = DeepSeek(model="deepseek-reasoner")
Settings.embed_model = SiliconFlowEmbedding(api_key=siliconflow_key)
Settings.chunk_size = 512
Settings.chunk_overlap = 50

# ====================== LEVEL INSTRUCTIONS ======================
LEVEL_INSTRUCTIONS = {
    "beginner": "You are a patient ICT tutor for Secondary 2–4 students. Simplify everything, use everyday analogies, explain jargon, and keep the tone encouraging.",
    "intermediate": "You are an ICT tutor helping Secondary 4–6 students aiming for HKDSE grade 3–4 or post-secondary students revising. Give clear, balanced explanations.",
    "advanced": "You are an expert ICT tutor preparing students for top HKDSE grades (5**). Provide detailed technical depth and reference past HKDSE paper styles."
}

# ====================== LOAD / BUILD VECTOR INDEX ======================
def load_index():
    db = chromadb.PersistentClient(path="./chroma_ict_db")
    collection = db.get_or_create_collection("ict_knowledge")
    vector_store = ChromaVectorStore(chroma_collection=collection)
    storage_context = StorageContext.from_defaults(vector_store=vector_store)

    if collection.count() > 0:
        print("Loading existing vector database...")
        return VectorStoreIndex.from_vector_store(vector_store)
    else:
        print("Building new vector database from data_markdown...")
        documents = SimpleDirectoryReader("data_markdown", recursive=True).load_data()
        return VectorStoreIndex.from_documents(documents, storage_context=storage_context, show_progress=True)

index = load_index()
retriever = index.as_retriever(similarity_top_k=5)

print("RAG system ready!")

def is_ready() -> bool:
    return True

# ====================== RESPONSE TYPE PROMPTS ======================
RESPONSE_TYPE_PROMPTS = {
    "chat": """Respond in a concise, conversational manner. Keep your answer to no more than 7 sentences.
Be friendly and direct. Do not use markdown formatting or bullet points.""",

    "notes": """Respond ONLY with a valid JSON object (no markdown, no code fences, no extra text).
The JSON must follow this exact structure:
{{
  "title": "Topic title",
  "sections": [
    {{
      "heading": "Section heading",
      "points": ["Key point 1", "Key point 2"]
    }}
  ],
  "summary": "A brief summary of the topic"
}}
Ensure the notes are well-organized and comprehensive.""",

    "quiz": """Respond ONLY with a valid JSON object (no markdown, no code fences, no extra text).
The JSON must follow this exact structure:
{{
  "question": "A clear multiple-choice question about the topic",
  "options": {{
    "A": "First option",
    "B": "Second option",
    "C": "Third option",
    "D": "Fourth option"
  }},
  "answer": "The correct option letter (A, B, C, or D)",
  "explanation": "Explain the correct answer in no more than 50 words"
}}
Make sure exactly one option is correct and the distractors are plausible."""
}

# ====================== ADAPTIVE QUERY FUNCTION ======================
def adaptive_query(question: str, user_level: str = "intermediate", response_type: str = "chat") -> str:
    level = user_level.lower().strip()
    if level not in LEVEL_INSTRUCTIONS:
        level = "intermediate"

    rtype = response_type.lower().strip()
    if rtype not in RESPONSE_TYPE_PROMPTS:
        rtype = "chat"

    nodes = retriever.retrieve(question)
    context_str = "\n\n".join([n.node.get_content() for n in nodes])

    synthesis_prompt = PromptTemplate(
        f"""{{context_str}}

User level: {level.upper()}
{LEVEL_INSTRUCTIONS[level]}

Response format: {rtype.upper()}
{RESPONSE_TYPE_PROMPTS[rtype]}

Question: {{query_str}}"""
    )

    response = Settings.llm.complete(synthesis_prompt.format(context_str=context_str, query_str=question))
    return response.text
