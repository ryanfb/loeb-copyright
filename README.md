# loeb-copyright

This repository is intended for collaborative assessment of the (primarily U.S.) copyright status of volumes in the Loeb Classical Library, with an eye to eventual inclusion of scans for out-of-copyright volumes in [Loebolus](https://ryanfb.github.io/loebolus/) and other projects.

Work will happen in `loeb-copyright.csv`, with the fields:

* `identifier` - e.g. L001
* `author` - ancient author
* `title` - human-readable title of the work
* `year_published` - year of first publication *of this translation*
* `translator` - name of the translator with most recent year of death
* `translator_year_of_death` - year of death of the translator with most recent year of death, blank if unknown, `N/A` if still living
* `pre_1923` - true if `year_published < 1923`
* `1923-1963_copyright_not_renewed` - true if `1923 <= year_published <= 1963` *and* verified that copyright was not renewed, false if verified that copyright *was* renewed, undefined if not checked/known
* `in_loebolus` - true if a PDF for this identifier is in Loebolus
* `notes` - free-form descriptive text for work notes
* `urls` - space-separated list of associated URLs (Internet Archive, Google Books, link to page with metadata about *this translation*, etc.)

A work is public domain in the U.S. if `pre_1923` or `1923-1963_copyright_not_renewed` are `true`.

Note that some Loebs were published with different works/editions/translations under the same "number". Outside of differentiating via `title`/`year_published`, you may want to note these cases in `notes`.

Helpful links:

* [Stanford Copyright Renewal Database](https://exhibits.stanford.edu/copyrightrenewals)
* [Online Books Page Copyright Registration and Renewal Records](http://onlinebooks.library.upenn.edu/cce/)
* [US Copyright Office Public Catalog (1978-present)](http://cocatalog.loc.gov/cgi-bin/Pwebrecon.cgi?DB=local&PAGE=First)
* The source of [Bill Thayer's "A Selection of Articles from Various Journals in the Fields of Classics and Archaeology"](http://penelope.uchicago.edu/Thayer/E/Journals/Roman/home.html) has a `DEATHDATES` field for checking 70-years-since-author-death
* [Cornell's "Copyright Term and the Public Domain in the United States"](http://copyright.cornell.edu/resources/publicdomain.cfm)
* [DownLOEBables](http://www.edonnelly.com/loebs.html)
