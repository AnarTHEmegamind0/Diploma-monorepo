"""
MongoDB database connection using Motor (async driver).
"""

from motor.motor_asyncio import AsyncIOMotorClient
from .config import settings


class Database:
    """MongoDB connection manager."""

    client: AsyncIOMotorClient = None
    db = None

    async def connect(self):
        """Connect to MongoDB."""
        self.client = AsyncIOMotorClient(settings.MONGODB_URI)
        self.db = self.client[settings.MONGODB_DB_NAME]
        print(f"Connected to MongoDB: {settings.MONGODB_DB_NAME}")

    async def disconnect(self):
        """Disconnect from MongoDB."""
        if self.client:
            self.client.close()
            print("Disconnected from MongoDB")

    def get_collection(self, name: str):
        """Get a MongoDB collection."""
        return self.db[name]


# Global database instance
database = Database()


# Collection accessors
def get_products_collection():
    return database.get_collection("products")


def get_detections_collection():
    return database.get_collection("detections")


def get_audits_collection():
    return database.get_collection("audits")


# New collections for audit system
def get_auditors_collection():
    return database.get_collection("auditors")


def get_groups_collection():
    return database.get_collection("groups")


def get_tradeshops_collection():
    return database.get_collection("tradeshops")


def get_categories_collection():
    return database.get_collection("categories")


def get_campaigns_collection():
    return database.get_collection("campaigns")


def get_surveys_collection():
    return database.get_collection("surveys")


def get_questions_collection():
    return database.get_collection("questions")


def get_question_groups_collection():
    return database.get_collection("question_groups")


def get_audit_responses_collection():
    return database.get_collection("audit_responses")
