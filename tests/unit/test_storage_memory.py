import pytest
import time
from nvd_claude_proxy.services.storage.memory import InMemoryStorageEngine

@pytest.mark.asyncio
async def test_memory_idempotency_storage():
    storage = InMemoryStorageEngine()
    
    # 1. Test saving and retrieving
    await storage.save_idempotency("key1", {"message": "success"}, ttl=2)
    resp = await storage.get_idempotency("key1")
    assert resp == {"message": "success"}
    
    # 2. Test expiration
    await storage.save_idempotency("key2", {"message": "expiring"}, ttl=0.1)
    time.sleep(0.15)
    resp = await storage.get_idempotency("key2")
    assert resp is None
    
    # 3. Test missing key
    assert await storage.get_idempotency("key3") is None
