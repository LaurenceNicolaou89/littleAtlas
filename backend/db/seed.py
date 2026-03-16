"""Seed script -- populates categories table with initial data."""

import asyncio
import os
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from sqlalchemy import text

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+asyncpg://atlas:atlas@localhost:5432/littleatlas",
)

CATEGORIES = [
    {"slug": "outdoor_playground", "name_en": "Outdoor Playground", "name_el": "Υπαίθρια Παιδική Χαρά", "name_ru": "Уличная площадка", "icon": "child_care"},
    {"slug": "indoor_playground", "name_en": "Indoor Playground", "name_el": "Εσωτερική Παιδική Χαρά", "name_ru": "Крытая площадка", "icon": "child_care"},
    {"slug": "park", "name_en": "Park", "name_el": "Πάρκο", "name_ru": "Парк", "icon": "park"},
    {"slug": "beach", "name_en": "Beach", "name_el": "Παραλία", "name_ru": "Пляж", "icon": "beach_access"},
    {"slug": "nature_trail", "name_en": "Nature Trail", "name_el": "Μονοπάτι Φύσης", "name_ru": "Природная тропа", "icon": "hiking"},
    {"slug": "botanical_garden", "name_en": "Botanical Garden", "name_el": "Βοτανικός Κήπος", "name_ru": "Ботанический сад", "icon": "local_florist"},
    {"slug": "family_restaurant", "name_en": "Family Restaurant", "name_el": "Οικογενειακό Εστιατόριο", "name_ru": "Семейный ресторан", "icon": "restaurant"},
    {"slug": "cafe_with_play_area", "name_en": "Cafe with Play Area", "name_el": "Καφετέρια με Παιδότοπο", "name_ru": "Кафе с игровой зоной", "icon": "local_cafe"},
    {"slug": "fast_food_with_playground", "name_en": "Fast Food with Playground", "name_el": "Φαστ Φουντ με Παιδική Χαρά", "name_ru": "Фастфуд с площадкой", "icon": "fastfood"},
    {"slug": "luna_park", "name_en": "Luna Park", "name_el": "Λούνα Παρκ", "name_ru": "Луна-парк", "icon": "attractions"},
    {"slug": "arcade", "name_en": "Arcade", "name_el": "Ηλεκτρονικά Παιχνίδια", "name_ru": "Аркада", "icon": "sports_esports"},
    {"slug": "bowling", "name_en": "Bowling", "name_el": "Μπόουλινγκ", "name_ru": "Боулинг", "icon": "sports"},
    {"slug": "mini_golf", "name_en": "Mini Golf", "name_el": "Μίνι Γκολφ", "name_ru": "Мини-гольф", "icon": "golf_course"},
    {"slug": "cinema", "name_en": "Cinema", "name_el": "Σινεμά", "name_ru": "Кинотеатр", "icon": "movie"},
    {"slug": "trampoline_park", "name_en": "Trampoline Park", "name_el": "Πάρκο Τραμπολίνο", "name_ru": "Батутный парк", "icon": "fitness_center"},
    {"slug": "museum", "name_en": "Museum", "name_el": "Μουσείο", "name_ru": "Музей", "icon": "museum"},
    {"slug": "library", "name_en": "Library", "name_el": "Βιβλιοθήκη", "name_ru": "Библиотека", "icon": "local_library"},
    {"slug": "aquarium", "name_en": "Aquarium", "name_el": "Ενυδρείο", "name_ru": "Аквариум", "icon": "water"},
    {"slug": "zoo", "name_en": "Zoo", "name_el": "Ζωολογικός Κήπος", "name_ru": "Зоопарк", "icon": "pets"},
    {"slug": "swimming_pool", "name_en": "Swimming Pool", "name_el": "Πισίνα", "name_ru": "Бассейн", "icon": "pool"},
    {"slug": "climbing_wall", "name_en": "Climbing Wall", "name_el": "Αναρριχητικός Τοίχος", "name_ru": "Скалодром", "icon": "terrain"},
    {"slug": "sports_center", "name_en": "Sports Center", "name_el": "Αθλητικό Κέντρο", "name_ru": "Спортивный центр", "icon": "sports_soccer"},
    {"slug": "water_park", "name_en": "Water Park", "name_el": "Υδάτινο Πάρκο", "name_ru": "Аквапарк", "icon": "water_drop"},
]


async def seed():
    engine = create_async_engine(DATABASE_URL)
    async_session = sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        for cat in CATEGORIES:
            await session.execute(
                text(
                    "INSERT INTO categories (slug, name_en, name_el, name_ru, icon) "
                    "VALUES (:slug, :name_en, :name_el, :name_ru, :icon) "
                    "ON CONFLICT (slug) DO UPDATE SET "
                    "name_en = :name_en, name_el = :name_el, name_ru = :name_ru, icon = :icon"
                ),
                cat,
            )
        await session.commit()

    await engine.dispose()
    print(f"Seeded {len(CATEGORIES)} categories.")


if __name__ == "__main__":
    asyncio.run(seed())
