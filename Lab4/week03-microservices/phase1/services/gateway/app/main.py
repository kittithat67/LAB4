from fastapi import FastAPI, UploadFile, File, HTTPException, BackgroundTasks, Form
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from datetime import datetime
import httpx
import asyncio
import logging
from typing import Optional, Dict, Any
import os
import json
from dotenv import load_dotenv


# Load environment variables
load_dotenv()


# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


app = FastAPI(title="Phase 1 Gateway Service", version="1.0.0")


# Service URLs
UPLOAD_SERVICE_URL = os.getenv("UPLOAD_SERVICE_URL", "http://localhost:8001")
PROCESSING_SERVICE_URL = os.getenv("PROCESSING_SERVICE_URL", "http://localhost:8002")
AI_SERVICE_URL = os.getenv("AI_SERVICE_URL", "http://localhost:8003")


class ProcessingRequest(BaseModel):
    enable_processing: bool = True
    processing_operation: str = "thumbnail"
    enable_ai_analysis: bool = True
    ai_analysis_type: str = "general"


class WorkflowResponse(BaseModel):
    workflow_id: str
    file_id: str
    upload_status: str
    processing_status: Optional[str] = None
    ai_analysis_status: Optional[str] = None
    total_time: float
    timestamp: str


# --- Helper functions ---
async def upload_file(file: UploadFile) -> Dict[str, Any]:
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            files = {"file": (file.filename, file.file, file.content_type)}
            response = await client.post(f"{UPLOAD_SERVICE_URL}/upload", files=files)
            if response.status_code != 200:
                raise HTTPException(status_code=response.status_code, detail=f"Upload error: {response.text}")
            return response.json()
    except Exception as e:
        logger.error(f"Upload failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


async def process_file(file_id: str, operation: str) -> Dict[str, Any]:
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(f"{PROCESSING_SERVICE_URL}/process/{file_id}", json={"operation": operation, "parameters": {}})
            return response.json()
    except Exception as e:
        return {"status": f"failed: {str(e)}"}


async def analyze_file(file_id: str, analysis_type: str) -> Dict[str, Any]:
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.post(f"{AI_SERVICE_URL}/analyze/{file_id}", json={"analysis_type": analysis_type, "confidence_threshold": 0.7})
            return response.json()
    except Exception as e:
        return {"status": f"failed: {str(e)}"}


# --- Endpoints ---
@app.get("/health")
async def health_check():
    """Health check endpoint ที่คืนค่าครบตามสคริปต์ start_services.py ต้องการ"""
    start_time = datetime.now()
   
    # รายชื่อ Services ที่ต้องไปไล่เช็คสถานะ
    services_to_check = {
        "upload": f"{UPLOAD_SERVICE_URL}/health",
        "processing": f"{PROCESSING_SERVICE_URL}/health",
        "ai": f"{AI_SERVICE_URL}/health"
    }
   
    services_status = {
        "gateway": {"status": "healthy"}
    }
   
    overall_healthy = True
    async with httpx.AsyncClient(timeout=2.0) as client:
        for name, url in services_to_check.items():
            try:
                resp = await client.get(url)
                if resp.status_code == 200:
                    services_status[name] = {"status": "healthy"}
                else:
                    services_status[name] = {"status": f"unhealthy ({resp.status_code})"}
                    overall_healthy = False
            except Exception as e:
                services_status[name] = {"status": f"unreachable: {str(e)}"}
                overall_healthy = False
   
    check_duration = (datetime.now() - start_time).total_seconds()
   
    return {
        "status": "healthy" if overall_healthy else "degraded",
        "timestamp": datetime.now().isoformat(),
        "check_duration": check_duration,
        "services": services_status  # Key สำคัญที่สคริปต์ start_services.py ตามหา
    }


@app.post("/process-file", response_model=WorkflowResponse)
async def process_file_endpoint(
    background_tasks: BackgroundTasks,
    file: UploadFile = File(...),
    processing_options: str = Form('{"enable_processing": true, "processing_operation": "thumbnail", "enable_ai_analysis": true, "ai_analysis_type": "general"}')
):
    try:
        options_dict = json.loads(processing_options)
        options = ProcessingRequest(**options_dict)
    except Exception:
        raise HTTPException(status_code=422, detail="Invalid processing_options JSON format")


    workflow_id = f"workflow_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    start_time = datetime.now()
   
    try:
        # Step 1: Upload
        upload_result = await upload_file(file)
        file_id = upload_result.get("file_id", "unknown")
       
        # Step 2 & 3: เรียกใช้ .get() เพื่อป้องกัน Error 500
        proc_res = await process_file(file_id, options.processing_operation) if options.enable_processing else None
        ai_res = await analyze_file(file_id, options.ai_analysis_type) if options.enable_ai_analysis else None
       
        total_time = (datetime.now() - start_time).total_seconds()
       
        return WorkflowResponse(
            workflow_id=workflow_id,
            file_id=file_id,
            upload_status="completed",
            # ใช้ .get("status") เพื่อดึงค่า ถ้าไม่มีให้เป็น "error" แทนที่จะพัง
            processing_status=proc_res.get("status", "error") if proc_res else "skipped",
            ai_analysis_status=ai_res.get("status", "error") if ai_res else "skipped",
            total_time=total_time,
            timestamp=datetime.now().isoformat()
        )
    except Exception as e:
        logger.error(f"Workflow {workflow_id} failed: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8090)

