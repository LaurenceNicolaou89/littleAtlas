"""add event_type column

Revision ID: 94ac2c591526
Revises: 001
Create Date: 2026-03-18 19:39:44.105258

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '94ac2c591526'
down_revision: Union[str, None] = '001'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.add_column('events', sa.Column('event_type', sa.String(length=50), nullable=True))


def downgrade() -> None:
    op.drop_column('events', 'event_type')
