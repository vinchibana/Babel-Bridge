import os
import shutil
from fastapi import FastAPI, UploadFile, Form
from fastapi.responses import FileResponse
import subprocess
from pathlib import Path
import uuid

app = FastAPI()

# 创建临时文件夹用于存储上传的文件和翻译结果
UPLOAD_DIR = Path("uploads")
UPLOAD_DIR.mkdir(exist_ok=True)

@app.post("/translate")
async def translate_book(
    file: UploadFile,
    translation_speed: str = Form(...),  # 'fast' or 'standard'
    translation_mode: str = Form(...),   # 'standard', 'professional', or 'literary'
    word_count: int = Form(...)
):
    # 创建唯一的工作目录
    work_dir = UPLOAD_DIR / str(uuid.uuid4())
    work_dir.mkdir()
    
    try:
        # 保存上传的文件
        file_path = work_dir / file.filename
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # 根据翻译模式选择合适的模型和参数
        model = "gpt-3.5-turbo" if translation_speed == "fast" else "gpt-4"
        
        # 构建翻译命令
        cmd = [
            "python3",
            "-m",
            "bbook_maker.make_book",
            "--book_name",
            str(file_path),
            "--model",
            "openai",
            "--model_list",
            model,
            "--language",
            "zh-hans",
        ]
        
        # 如果是快速模式，添加 --test 参数
        if translation_speed == "fast":
            cmd.append("--test")
            
        # 执行翻译
        process = subprocess.run(
            cmd,
            env={**os.environ, "OPENAI_API_KEY": os.getenv("OPENAI_API_KEY")},
            capture_output=True,
            text=True
        )
        
        if process.returncode != 0:
            raise Exception(f"Translation failed: {process.stderr}")
            
        # 查找生成的翻译文件
        translated_file = next(work_dir.glob("*.epub_translated.epub"))
        
        # 返回翻译后的文件
        return FileResponse(
            path=translated_file,
            filename=f"{file_path.stem}_translated.epub",
            media_type="application/epub+zip"
        )
        
    finally:
        # 清理临时文件
        shutil.rmtree(work_dir)

@app.get("/health")
async def health_check():
    return {"status": "healthy"} 
