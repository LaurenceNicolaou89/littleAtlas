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
        sa.Column('slug', sa.String(50), unique=True, nullable=False),
        sa.Column('name_en', sa.String(100), nullable=False),
        sa.Column('name_el', sa.String(100)),
        sa.Column('name_ru', sa.String(100)),
        sa.Column('icon', sa.String(50)),
    )

    # Places table
    op.create_table(
        'places',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('name_en', sa.String(255), nullable=False),
        sa.Column('name_el', sa.String(255)),
        sa.Column('name_ru', sa.String(255)),
        sa.Column('description_en', sa.Text()),
        sa.Column('description_el', sa.Text()),
        sa.Column('description_ru', sa.Text()),
        sa.Column('category_id', sa.Integer(), sa.ForeignKey('categories.id')),
        sa.Column('location', Geography('POINT', srid=4326), nullable=False),
        sa.Column('address', sa.String(500)),
        sa.Column('phone', sa.String(50)),
        sa.Column('website', sa.String(500)),
        sa.Column('opening_hours', JSONB()),
        sa.Column('is_indoor', sa.Boolean(), server_default='false'),
        sa.Column('age_min', sa.Integer(), server_default='0'),
        sa.Column('age_max', sa.Integer(), server_default='12'),
        sa.Column('amenities', JSONB(), server_default='[]'),
        sa.Column('photos', JSONB(), server_default='[]'),
        sa.Column('source', sa.String(50)),
        sa.Column('source_id', sa.String(255)),
        sa.Column('last_verified_at', sa.DateTime()),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(), server_default=sa.func.now()),
    )

    # Spatial and category indexes on places
    op.create_index('idx_places_location', 'places', ['location'], postgresql_using='gist')
    op.create_index('idx_places_category', 'places', ['category_id'])

    # Events table
    op.create_table(
        'events',
        sa.Column('id', sa.Integer(), primary_key=True),
        sa.Column('title_en', sa.String(255), nullable=False),
        sa.Column('title_el', sa.String(255)),
        sa.Column('title_ru', sa.String(255)),
        sa.Column('description_en', sa.Text()),
        sa.Column('description_el', sa.Text()),
        sa.Column('description_ru', sa.Text()),
        sa.Column('location', Geography('POINT', srid=4326)),
        sa.Column('venue_name', sa.String(255)),
        sa.Column('address', sa.String(500)),
        sa.Column('start_date', sa.DateTime(), nullable=False),
        sa.Column('end_date', sa.DateTime()),
        sa.Column('is_indoor', sa.Boolean(), server_default='false'),
        sa.Column('age_min', sa.Integer(), server_default='0'),
        sa.Column('age_max', sa.Integer(), server_default='12'),
        sa.Column('source_url', sa.String(500)),
        sa.Column('source', sa.String(50)),
        sa.Column('created_at', sa.DateTime(), server_default=sa.func.now()),
    )

    op.create_index('idx_events_location', 'events', ['location'], postgresql_using='gist')
    op.create_index('idx_events_dates', 'events', ['start_date', 'end_date'])


def downgrade() -> None:
    op.drop_table('events')
    op.drop_table('places')
    op.drop_table('categories')
    op.execute('DROP EXTENSION IF EXISTS postgis')
