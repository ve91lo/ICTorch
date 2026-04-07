import nest_asyncio
import os
from llama_parse import LlamaParse
from llama_index.core import SimpleDirectoryReader
from fastapi.responses import JSONResponse
import base64
from pathlib import Path

nest_asyncio.apply()

# ====================== CONFIG ======================
LLAMA_CLOUD_API_KEY = "llx-EUthbYf9STMRTpuTp4rw2us4nYJqIoejzj4j6ZX62cHu1BdE"   # ← Put your real key here

parser = LlamaParse(
    api_key=LLAMA_CLOUD_API_KEY,
    result_type="markdown",
    verbose=True,
    num_workers=4,
    parsing_instruction="Extract all text, tables, code, and describe every diagram, screenshot, flowchart, or image in detail. For each image, output a markdown image placeholder like: ![Diagram](image_id:xyz) followed by a clear description."
)

file_extractor = {".pdf": parser}

# ====================== PARSE ALL THREE FOLDERS ======================
root_dirs = [
    "data/learning_materials",
    "data/assessment",
    "data/assessment_answers"
]

documents = []
for dir_path in root_dirs:
    if os.path.exists(dir_path):
        print(f"Parsing folder: {dir_path}")
        docs = SimpleDirectoryReader(
            input_dir=dir_path,
            recursive=True,
            file_extractor=file_extractor
        ).load_data()
        documents.extend(docs)
        print(f"  → Parsed {len(docs)} documents from {dir_path}")
    else:
        print(f"Warning: Folder not found - {dir_path}")

print(f"\n✅ Total documents parsed: {len(documents)}")

# ====================== SAVE MARKDOWN (preserves original structure) ======================
output_root = "parsed_markdown"
os.makedirs(output_root, exist_ok=True)

for doc in documents:
    file_path = doc.metadata.get("file_path", "unknown.pdf")

    # Get relative path from "data/" so structure is preserved
    relative_path = os.path.relpath(file_path, "data")
    subfolder = os.path.dirname(relative_path)

    output_dir = os.path.join(output_root, subfolder)
    os.makedirs(output_dir, exist_ok=True)

    filename = os.path.basename(file_path).replace(".pdf", ".md")
    output_path = os.path.join(output_dir, filename)

    content = f"""---
source_file: {os.path.basename(file_path)}
category: {os.path.dirname(subfolder).split(os.sep)[-1] if subfolder else "root"}
subtopic: {os.path.basename(subfolder) if subfolder else "general"}
---

{doc.text}
"""

    with open(output_path, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Saved: {output_path}")
