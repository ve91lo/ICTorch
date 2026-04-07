import json
import os
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from rag_core import adaptive_query, is_ready
from typing import List, Optional
import uvicorn

# ---------------------------------------------------------------------------
# Supabase client (graceful if not configured)
# ---------------------------------------------------------------------------
try:
    from supabase import create_client
    SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
    SUPABASE_SERVICE_ROLE_KEY = os.environ.get("SUPABASE_SERVICE_ROLE_KEY", "")
    if SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY:
        supabase = create_client(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY)
    else:
        supabase = None
except Exception:
    supabase = None

app = FastAPI(title="ICT Adaptive RAG API")

# ---------------------------------------------------------------------------
# Pydantic models
# ---------------------------------------------------------------------------
class QueryRequest(BaseModel):
    question: str
    user_level: str = "intermediate"   # beginner / intermediate / advanced
    response_type: str = "chat"        # chat / notes / quiz

class AuthCallbackRequest(BaseModel):
    code: str
    redirect_uri: Optional[str] = None

class SyncProgressRequest(BaseModel):
    user_id: str
    completed_topics: List[str]

class QuizAnswer(BaseModel):
    question: str
    selected_answer: str
    correct_answer: str
    is_correct: bool

class SyncQuizRequest(BaseModel):
    user_id: str
    topic: str
    score: int
    total: int
    answers: List[QuizAnswer]

class UpsertUserRequest(BaseModel):
    user_id: str
    email: Optional[str] = None
    display_name: Optional[str] = None
    photo_url: Optional[str] = None
    provider: Optional[str] = None

# ---------------------------------------------------------------------------
# Existing endpoints (unchanged)
# ---------------------------------------------------------------------------
@app.get("/health")
async def health():
    if is_ready():
        return {"status": "ready"}
    return {"status": "loading"}

@app.post("/query")
async def query_rag(req: QueryRequest):
    rtype = req.response_type.lower().strip()
    if rtype not in ("chat", "notes", "quiz"):
        rtype = "chat"

    answer = adaptive_query(req.question, req.user_level, rtype)

    if rtype in ("notes", "quiz"):
        try:
            parsed = json.loads(answer)
            return {"answer": parsed, "level": req.user_level.capitalize(), "response_type": rtype}
        except json.JSONDecodeError:
            return {"answer": answer, "level": req.user_level.capitalize(), "response_type": rtype}

    return {"answer": answer, "level": req.user_level.capitalize(), "response_type": rtype}

# ---------------------------------------------------------------------------
# Auth endpoints
# ---------------------------------------------------------------------------
@app.post("/auth/callback")
async def auth_callback(req: AuthCallbackRequest):
    """Handle OAuth callback – exchange code for session via Supabase."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        response = supabase.auth.exchange_code_for_session({"auth_code": req.code})
        return {
            "access_token": response.session.access_token,
            "refresh_token": response.session.refresh_token,
            "user": {
                "id": response.user.id,
                "email": response.user.email,
            },
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))

# ---------------------------------------------------------------------------
# Sync – Topic Progress
# ---------------------------------------------------------------------------
@app.post("/sync/progress")
async def sync_progress(req: SyncProgressRequest):
    """Upsert completed-topics list for a user."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        data = {
            "user_id": req.user_id,
            "completed_topics": req.completed_topics,
        }
        result = (
            supabase.table("user_progress")
            .upsert(data, on_conflict="user_id")
            .execute()
        )
        return {"status": "ok", "data": result.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/sync/progress/{user_id}")
async def get_progress(user_id: str):
    """Return the user's completed topics."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        result = (
            supabase.table("user_progress")
            .select("*")
            .eq("user_id", user_id)
            .execute()
        )
        if result.data:
            return {"status": "ok", "data": result.data[0]}
        return {"status": "ok", "data": {"user_id": user_id, "completed_topics": []}}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ---------------------------------------------------------------------------
# Sync – Quiz History
# ---------------------------------------------------------------------------
@app.post("/sync/quiz")
async def sync_quiz(req: SyncQuizRequest):
    """Save a quiz attempt."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        data = {
            "user_id": req.user_id,
            "topic": req.topic,
            "score": req.score,
            "total": req.total,
            "answers": [a.model_dump() for a in req.answers],
        }
        result = supabase.table("quiz_attempts").insert(data).execute()
        return {"status": "ok", "data": result.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/sync/quiz/{user_id}")
async def get_quiz_history(user_id: str):
    """Return all quiz attempts for a user, newest first."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        result = (
            supabase.table("quiz_attempts")
            .select("*")
            .eq("user_id", user_id)
            .order("created_at", desc=True)
            .execute()
        )
        return {"status": "ok", "data": result.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# ---------------------------------------------------------------------------
# Sync – User Profile
# ---------------------------------------------------------------------------
@app.post("/sync/user")
async def upsert_user(req: UpsertUserRequest):
    """Create or update a user profile row."""
    if not supabase:
        raise HTTPException(status_code=503, detail="Supabase not configured")
    try:
        data = {"user_id": req.user_id}
        if req.email is not None:
            data["email"] = req.email
        if req.display_name is not None:
            data["display_name"] = req.display_name
        if req.photo_url is not None:
            data["photo_url"] = req.photo_url
        if req.provider is not None:
            data["provider"] = req.provider

        result = (
            supabase.table("users")
            .upsert(data, on_conflict="user_id")
            .execute()
        )
        return {"status": "ok", "data": result.data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# For local testing
if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
