"""Initial schema -- categories, places, events tables with PostGIS

Revision ID: 001
Revises:
Create Date: 2026-03-17

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import JSONB
from geoalchemy2 import Geography

# revision identifiers, used by Alembic.
revision: str = '001'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # Enable PostGIS extension
    op.execute('CREATE EXTENSION IF NOT EXISTS postgis')

    # Categories table
    op.create_table(
        'categories',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('slug', sa.String(64), unique=True, nullable=False),
        sa.Column('name_en', sa.String(128), nullable=False),
        sa.Column('name_el', sa.String(128), nullable=False, server_default=''),
        sa.Column('name_ru', sa.String(128), nullable=False, server_default=''),
        sa.Column('icon', sa.String(64), nullable=False, server_default=''),
    )

    # Places table
    op.create_table(
        'places',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name_en', sa.String(256), nullable=False),
        sa.Column('name_el', sa.String(256), nullable=False, server_default=''),
        sa.Column('name_ru', sa.String(256), nullable=False, server_default=''),
        sa.Column('description_en', sa.Text(), nullable=False, server_default=''),
        sa.Column('description_el', sa.Text(), nullable=False, server_default=''),
        sa.Column('description_ru', sa.Text(), nullable=False, server_default=''),
        sa.Column('category_id', sa.Integer(), sa.ForeignKey('categories.id'), nullable=True),
        sa.Column('location', Geography('POINT', srid=4326), nullable=False),
        sa.Column('address', sa.String(512), nullable=False, server_default=''),
        sa.Column('phone', sa.String(32), nullable=False, server_default=''),
        sa.Column('website', sa.String(512), nullable=False, server_default=''),
        sa.Column('opening_hours', JSONB(), nullable=True),
        sa.Column('is_indoor', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('age_min', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('age_max', sa.Integer(), nullable=False, server_default='18'),
        sa.Column('amenities', JSONB(), nullable=False, server_default='[]'),
        sa.Column('photos', JSONB(), nullable=False, server_default='[]'),
        sa.Column('source', sa.String(64), nullable=False, server_default='manual'),
        sa.Column('source_id', sa.String(256), nullable=True),
        sa.Column('last_verified_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    # Spatial and category indexes on places
    op.create_index('idx_places_location', 'places', ['location'], postgresql_using='gist')
    op.create_index('idx_places_category', 'places', ['category_id'])

    # Events table
    op.create_table(
        'events',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('title_en', sa.String(256), nullable=False),
        sa.Column('title_el', sa.String(256), nullable=False, server_default=''),
        sa.Column('title_ru', sa.String(256), nullable=False, server_default=''),
        sa.Column('description_en', sa.Text(), nullable=False, server_default=''),
        sa.Column('description_el', sa.Text(), nullable=False, server_default=''),
        sa.Column('description_ru', sa.Text(), nullable=False, server_default=''),
        sa.Column('location', Geography('POINT', srid=4326), nullable=True),
        sa.Column('venue_name', sa.String(256), nullable=False, server_default=''),
        sa.Column('address', sa.String(512), nullable=False, server_default=''),
        sa.Column('start_date', sa.DateTime(timezone=True), nullable=False),
        sa.Column('end_date', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_indoor', sa.Boolean(), nullable=False, server_default='false'),
        sa.Column('age_min', sa.Integer(), nullable=False, server_default='0'),
        sa.Column('age_max', sa.Integer(), nullable=False, server_default='18'),
        sa.Column('source_url', sa.String(512), nullable=True),
        sa.Column('source', sa.String(64), nullable=False, server_default='manual'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now(), nullable=False),
    )

    op.create_index('idx_events_location', 'events', ['location'], postgresql_using='gist')
    op.create_index('idx_events_dates', 'events', ['start_date', 'end_date'])


def downgrade() -> None:
    op.drop_table('events')
    op.drop_table('places')
    op.drop_table('categories')
    op.execute('DROP EXTENSION IF EXISTS postgis')
