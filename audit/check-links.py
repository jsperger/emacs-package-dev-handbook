#!/usr/bin/env python3
"""check-links.py — Extract external URLs from README.org and check them.

Usage: python3 audit/check-links.py [README.org]

Prints TSV: URL \t section \t HTTP status \t disposition
Disposition: ok (2xx), redirect (3xx), dead (4xx/5xx/timeout/error)
"""

import re
import sys
import urllib.request
import urllib.error
from concurrent.futures import ThreadPoolExecutor, as_completed

TIMEOUT = 15
PARALLEL = 10
USER_AGENT = "Mozilla/5.0 (compatible; EPDH-link-checker)"


def extract_urls(path):
    """Yield (url, section) pairs from an Org file."""
    section = "(preamble)"
    url_re = re.compile(r"https?://[^\s\"<>\]\)]+")
    org_link_re = re.compile(r"\[\[(https?://[^\]]+)\]")

    with open(path, encoding="utf-8") as f:
        for line in f:
            heading = re.match(r"^\*\* (.+?)(?:\s+:[\w:]+:)?\s*$", line)
            if heading:
                section = heading.group(1).strip()
                continue

            seen = set()
            # Org links first: [[url][desc]] or [[url]]
            for m in org_link_re.finditer(line):
                url = m.group(1)
                if url not in seen:
                    seen.add(url)
                    yield url, section

            # Bare URLs (strip trailing punctuation)
            stripped = org_link_re.sub("", line)
            for m in url_re.finditer(stripped):
                url = m.group(0).rstrip(".,;:!?")
                if url not in seen:
                    seen.add(url)
                    yield url, section


def check_url(url, section):
    """Return (url, section, status_code, disposition)."""
    try:
        req = urllib.request.Request(url, method="HEAD",
                                     headers={"User-Agent": USER_AGENT})
        resp = urllib.request.urlopen(req, timeout=TIMEOUT)
        status = resp.status
    except urllib.error.HTTPError as e:
        status = e.code
    except Exception:
        # Try GET if HEAD fails (some servers reject HEAD)
        try:
            req = urllib.request.Request(url, method="GET",
                                         headers={"User-Agent": USER_AGENT})
            resp = urllib.request.urlopen(req, timeout=TIMEOUT)
            status = resp.status
        except urllib.error.HTTPError as e:
            status = e.code
        except Exception:
            status = 0

    if 200 <= status < 300:
        disposition = "ok"
    elif 300 <= status < 400:
        disposition = "redirect"
    else:
        disposition = "dead"

    return url, section, status, disposition


def main():
    path = sys.argv[1] if len(sys.argv) > 1 else "README.org"
    urls = list(dict.fromkeys(extract_urls(path)))  # dedupe, preserve order
    print(f"Checking {len(urls)} unique URLs "
          f"(timeout={TIMEOUT}s, parallel={PARALLEL})...", file=sys.stderr)

    results = []
    with ThreadPoolExecutor(max_workers=PARALLEL) as pool:
        futures = {pool.submit(check_url, url, sec): (url, sec)
                   for url, sec in urls}
        done = 0
        for fut in as_completed(futures):
            results.append(fut.result())
            done += 1
            if done % 25 == 0:
                print(f"  {done}/{len(urls)}...", file=sys.stderr)

    # Sort: dead first, then redirect, then ok; within group by URL
    order = {"dead": 0, "redirect": 1, "ok": 2}
    results.sort(key=lambda r: (order.get(r[3], 3), r[0]))

    for url, section, status, disposition in results:
        print(f"{url}\t{section}\t{status}\t{disposition}")

    print(f"Done. {len(results)} URLs checked.", file=sys.stderr)


if __name__ == "__main__":
    main()
