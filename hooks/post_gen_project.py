#!/usr/bin/env python
from __future__ import annotations

import os
import shutil

PROJECT_DIRECTORY = os.path.realpath(os.path.curdir)


def remove_file(filepath: str) -> None:
    os.remove(os.path.join(PROJECT_DIRECTORY, filepath))


def remove_dir(filepath: str) -> None:
    shutil.rmtree(os.path.join(PROJECT_DIRECTORY, filepath))


def move_file(filepath: str, target: str) -> None:
    os.rename(
        os.path.join(PROJECT_DIRECTORY, filepath),
        os.path.join(PROJECT_DIRECTORY, target),
    )


def move_dir(src: str, target: str) -> None:
    shutil.move(
        os.path.join(PROJECT_DIRECTORY, src), os.path.join(PROJECT_DIRECTORY, target)
    )


if __name__ == "__main__":
    move_file(".env_template", ".env")
