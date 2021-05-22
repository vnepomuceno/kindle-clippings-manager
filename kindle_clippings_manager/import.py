import json
import logging
from dataclasses import dataclass
from typing import Iterable

import click as click
import ftfy as ftfy

logging.getLogger().setLevel(logging.INFO)


@dataclass
class Clipping:
    book_name: str
    book_author: str
    clipping_location: str
    clipping_content: str
    datetime: str


def book_name_attr(clipping: Clipping) -> str:
    return clipping.book_name


class ClippingsService:
    def __init__(self, clippings_filepath: str, json_filepath: str):
        self.clippings_filepath = clippings_filepath
        self.separator = "=========="
        self.json_filepath = json_filepath

    def get_clippings(self) -> Iterable[None]:
        logging.info(f"Reading Kindle clippings from file {self.clippings_filepath}")

        """ Read content from file """
        with open(self.clippings_filepath) as file:
            content = file.read()

        """ Text processing and filtering """
        content = ftfy.fix_text(content)
        raw_clippings = [
            entry[1:] if entry.startswith("\n") else entry
            for entry in content.split(self.separator)
        ]
        raw_clippings = list(filter(lambda c: c != "", raw_clippings))

        """ Convert to dataclass objects """
        clippings = [
            Clipping(
                book_name=entry.split("\n\n")[0]
                .split("\n")[0]
                .split(" (")[0]
                .replace('"', ""),
                book_author=entry.split("\n\n")[0]
                .split("\n")[0]
                .split(" (")[1]
                .replace(")", ""),
                clipping_location=entry.split("\n\n")[0]
                .split("\n")[1]
                .split(" | ")[0]
                .split("on ")[1],
                clipping_content=entry.split("\n\n")[1].replace("\n", ""),
                datetime=entry.split("\n\n")[0]
                .split("\n")[1]
                .split(" | ")[1]
                .split("on ")[1],
            )
            for entry in raw_clippings
        ]

        """ Dump clippings to JSON"""
        sorted_clippings = sorted(clippings, key=book_name_attr)
        json_clippings = json.dumps(
            [clipping.__dict__ for clipping in sorted_clippings], ensure_ascii=False
        )

        """ Write JSON to output file"""
        with open(self.json_filepath, "w") as output_file:
            output_file.write(json_clippings)

        logging.info(
            f"Clippings successfully converted to JSON in {self.json_filepath}"
        )

        return clippings


@click.command()
def convert_clippings_to_json():
    ClippingsService(
        clippings_filepath="resources/My Clippings.txt",
        json_filepath="resources/clippings.json",
    ).get_clippings()


if __name__ == "__main__":
    convert_clippings_to_json()
