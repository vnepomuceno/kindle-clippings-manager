import asyncio
import json
import logging
from concurrent.futures import ThreadPoolExecutor
from dataclasses import dataclass
from typing import Iterable, Tuple, Dict, List, Callable, Optional, Union

import click as click
import ftfy as ftfy

logging.getLogger().setLevel(logging.INFO)


@dataclass
class Clipping:
    clipping_location: str
    clipping_content: str
    datetime: str


@dataclass
class BookClippings:
    book_name: str
    book_author: str
    clippings: List[Clipping]


class ClippingsService:
    def __init__(self, clippings_filepath: str, json_filepath: str):
        self.clippings_filepath = clippings_filepath
        self.separator = "=========="
        self.json_filepath = json_filepath

    @staticmethod
    def _extract_attributes(entry: str) -> Tuple[str, ...]:
        return (
            entry.split("\n\n")[0]
            .split("\n")[0]
            .split(" (")[0]
            .replace('"', ""),  # book name
            entry.split("\n\n")[0]
            .split("\n")[0]
            .split(" (")[1]
            .replace(")", ""),  # book author
            entry.split("\n\n")[0]
            .split("\n")[1]
            .split(" | ")[0]
            .split("on ")[1],  # location
            entry.split("\n\n")[1].replace("\n", ""),  # content
            entry.split("\n\n")[0]
            .split("\n")[1]
            .split(" | ")[1]
            .split("on ")[1],  # datetime
        )

    def export_clippings_to_json(
        self,
        clippings: Iterable[BookClippings],
        sort_rule: Optional[Callable[[BookClippings], str]] = None,
    ):
        """Dump clippings to JSON"""
        if sort_rule is not None:
            clippings = sorted(clippings, key=sort_rule)
        sorted_dict_clippings = self._get_clippings_dictionary(clippings)
        json_clippings = json.dumps(sorted_dict_clippings, ensure_ascii=False, indent=2)

        """ Write JSON to output file"""
        with open(self.json_filepath, "w") as output_file:
            output_file.write(json_clippings)

        logging.info(
            f"Clippings successfully converted to JSON in {self.json_filepath}"
        )

    @staticmethod
    def _get_clippings_dictionary(
        clippings: Iterable[BookClippings],
    ) -> Dict[str, Union[str, Dict[str, str]]]:
        """
        Converts an iterable of `BookClippings` into a JSON serializable dictionary.
        :param clippings: Iterable of `BookClippings` objects to be serialized.
        :return: Serializable dictionary of clippings.
        """
        clippings_dict = {}
        for item in clippings:
            clippings = [c.__dict__ for c in item.clippings]
            item.clippings = clippings
            clippings_dict[item.book_name] = item.__dict__

        return clippings_dict

    def _load_raw_clippings(self) -> Iterable[str]:
        """
        Loads raw clippings from file, processes its contents and returns an
        iterable of strings, each containing a raw clipping.
        :return: Iterable of raw clippings.
        """
        logging.info(f"Reading Kindle clippings from file {self.clippings_filepath}")

        """ Read content from file """
        with open(self.clippings_filepath) as file:
            content = file.read()

        """ Text processing and filtering """
        content = ftfy.fix_text(content)
        raw_clippings: Iterable[str] = [
            entry[1:] if entry.startswith("\n") else entry
            for entry in content.split(self.separator)
        ]
        raw_clippings = list(filter(lambda c: c != "", raw_clippings))

        return raw_clippings

    def _convert_to_dataclass_list(
        self, raw_clippings: Iterable[str]
    ) -> Iterable[BookClippings]:
        """
        Converts a list of iterable raw clippings into an iterable of objects
        of type `BookClippings`.
        :param raw_clippings: Iterable of raw clippings.
        :return: Iterable of objects of type `BookClippings`.
        """
        clippings_list: List[BookClippings] = []
        for book_name, author, location, content, date in [
            self._extract_attributes(entry) for entry in raw_clippings
        ]:
            new_clipping = Clipping(
                clipping_location=location, clipping_content=content, datetime=date
            )
            clipping_result = [
                item for item in clippings_list if item.book_name == book_name
            ]
            if len(clipping_result) == 0:
                clippings_list.append(
                    BookClippings(
                        book_name=book_name,
                        book_author=author,
                        clippings=[new_clipping],
                    )
                )
            else:
                if len(clipping_result[0].clippings) == 0:
                    clipping_result[0].clippings = [new_clipping]
                else:
                    clipping_result[0].clippings.append(new_clipping)

        return clippings_list

    def get_clippings(self) -> Iterable[BookClippings]:
        """
        Loads raw clippings from file and returns an iterable of objects
        of type `BookClippings`.
        :return: Iterable of objects of type `BookClippings`.
        """
        raw_clippings = self._load_raw_clippings()
        clippings_list = self._convert_to_dataclass_list(raw_clippings)

        return clippings_list


@click.command()
@click.option("--output-filepath", help="File path of the output")
def import_clippings_command(output_filepath):
    clipping_service = ClippingsService(
        clippings_filepath="resources/My Clippings.txt",
        json_filepath=output_filepath,
    )
    clipping_list: Iterable[BookClippings] = clipping_service.get_clippings()
    clipping_service.export_clippings_to_json(
        clippings=clipping_list, sort_rule=lambda clipping: clipping.book_name
    )


async def get_clippings_from_chunk():
    pass


if __name__ == "__main__":
    import_clippings_command()

    executor = ThreadPoolExecutor(max_workers=20)
    futures = asyncio.get_event_loop().run_in_executor(
        executor=executor, func=get_clippings_from_chunk
    )
    print(futures)
