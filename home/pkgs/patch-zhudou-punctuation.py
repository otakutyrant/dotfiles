"""Make Zhudou's centered punctuation its default OpenType behaviour.

Chromium can choose a font through Fontconfig but ignores Fontconfig's
``fontfeatures`` property.  Moving the relevant optional-feature lookups into
the always-enabled ``ccmp`` feature makes the result independent of browser
support for that property.
"""

import argparse

from fontTools.ttLib import TTFont


def feature_by_tag(font: TTFont, tag: str):
    for record in font["GSUB"].table.FeatureList.FeatureRecord:
        if record.FeatureTag == tag:
            return record.Feature
    raise ValueError(f"Zhudou does not contain the expected {tag!r} feature")


def disable_feature_lookups(font: TTFont, table_tag: str, tags: tuple[str, ...]) -> None:
    """Leave selected OpenType features present but make them no-ops."""
    for record in font[table_tag].table.FeatureList.FeatureRecord:
        if record.FeatureTag in tags:
            record.Feature.LookupListIndex = []
            record.Feature.LookupCount = 0


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("output")
    args = parser.parse_args()

    font = TTFont(args.input)
    default_feature = feature_by_tag(font, "ccmp")

    # Preserve Zhudou's original default substitutions, then add the optional
    # centered punctuation and half-width quote substitutions to that default.
    for tag in ("cpct", "hwid"):
        for lookup_index in feature_by_tag(font, tag).LookupListIndex:
            if lookup_index not in default_feature.LookupListIndex:
                default_feature.LookupListIndex.append(lookup_index)
    default_feature.LookupCount = len(default_feature.LookupListIndex)

    # Zhudou enables punctuation compression through the standard horizontal
    # and vertical kerning features by default. Empty their lookup lists so
    # every renderer leaves punctuation spacing untouched.
    disable_feature_lookups(font, "GPOS", ("kern", "vkrn"))

    font.save(args.output)


if __name__ == "__main__":
    main()
