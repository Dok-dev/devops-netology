import requests
import httpretty
import json
from pprint import pprint
from github import Github
from getpass import getpass

# https://python.hotexamples.com/ru/examples/kwalitee.tasks/-/pull_request/python-pull_request-function-examples.html
# https://pyneng.github.io/pyneng-3/GitHub-API-JSON-example/

def git_pull_request(owner, repository, session):
    """ pull_request /devops-netology/"""
    httpretty.reset()
    pull = {
        "title": "Lorem ipsum",
        "url": "https://api.github.com/devops-netology/1",
        "html_url": "https://github.com/pulls/1",
        "commits_url": "https://api.github.com/pulls/1/commits",
        "statuses_url": "https://api.github.com/statuses/2",
        "review_comments_url": "https://api.github.com/pulls/1/comments",
        "issue_url": "https://api.github.com/issues/1",
        "head": {
            "sha": "2",
            "label": "test:my-branch"
        },
        "base": {
            "repo": {
                "full_name": "kwalitee/test"
            },
            "ref": "testref"
        },
    }
    httpretty.register_uri(httpretty.GET,
                           "https://api.github.com/pulls/1",
                           body=json.dumps(pull),
                           content_type="application/json")

    httpretty.register_uri(httpretty.GET,
                           "https://api.github.com/repos/kwalitee/test/"
                           "contents/.kwalitee.yml?ref=testref",
                           status=404)

    issue = {
        "url": "https://api.github.com/issues/1",
        "html_url": "https://github.com/issues/1",
        "labels_url": "https://api.github.com/issues/1/labels{/name}",
        "id": "42",
        "number": "1",
        "labels": [{"name": "foo"},
                   {"name": "in_work"}],
        "state": "open"
    }
    httpretty.register_uri(httpretty.GET,
                           "https://api.github.com/issues/1",
                           body=json.dumps(issue),
                           content_type="application/json")
    labels = [{
        "url": "https://github.com/labels/foo",
        "name": "foo",
        "color": "000000"
    }, {
        "url": "https://github.com/labels/in_review",
        "name": "in_review",
        "color": "ff0000"
    }]
    httpretty.register_uri(httpretty.PUT,
                           "https://api.github.com/issues/1/labels",
                           status=200,
                           body=json.dumps(labels),
                           content_type="application/json")
    commits = [
        {
            "url": "https://api.github.com/commits/1",
            "sha": "1",
            "html_url": "https://github.com/commits/1",
            "comments_url": "https://api.github.com/commits/1/comments",
            "commit": {
                "message": "fix all the bugs!"
            }
        }, {

            "url": "https://api.github.com/commits/2",
            "sha": "2",
            "html_url": "https://github.com/commits/2",
            "comments_url": "https://api.github.com/commits/1/comments",
            "commit": {
                "message": "herp derp"
            }
        }
    ]
    httpretty.register_uri(httpretty.GET,
                           "https://api.github.com/pulls/1/commits",
                           body=json.dumps(commits),
                           content_type="application/json")
    files = [{
        "filename": "spam/eggs.py",
        "status": "added",
        "raw_url": "https://github.com/raw/2/spam/eggs.py",
        "contents_url": "https://api.github.com/spam/eggs.py?ref=2"
    }, {
        "filename": "spam/herp.html",
        "status": "added",
        "raw_url": "https://github.com/raw/2/spam/herp.html",
        "contents_url": "https://api.github.com/spam/herp.html?ref=2"
    }]
    httpretty.register_uri(httpretty.GET,
                           "https://api.github.com/pulls/1/files",
                           body=json.dumps(files),
                           content_type="application/json")
    eggs_py = "if foo == bar:\n  print('derp')\n"
    httpretty.register_uri(httpretty.GET,
                           "https://github.com/raw/2/spam/eggs.py",
                           body=eggs_py,
                           content_type="text/plain")
    herp_html = "<!DOCTYPE html><html><title>Hello!</title></html>"
    httpretty.register_uri(httpretty.GET,
                           "https://github.com/raw/2/spam/herp.html",
                           body=herp_html,
                           content_type="text/html")
    httpretty.register_uri(httpretty.POST,
                           "https://api.github.com/commits/1/comments",
                           status=201,
                           body=json.dumps({"id": 1}),
                           content_type="application/json")
    httpretty.register_uri(httpretty.POST,
                           "https://api.github.com/commits/2/comments",
                           status=201,
                           body=json.dumps({"id": 2}),
                           content_type="application/json")
    httpretty.register_uri(httpretty.POST,
                           "https://api.github.com/pulls/1/comments",
                           status=201,
                           body=json.dumps({"id": 3}),
                           content_type="application/json")
    status = {"id": 1, "state": "success"}
    httpretty.register_uri(httpretty.POST,
                           "https://api.github.com/statuses/2",
                           status=201,
                           body=json.dumps(status),
                           content_type="application/json")

    css = []
    for commit in commits:
        css.append(CommitStatus.find_or_create(repository,
                                               commit["sha"],
                                               commit["url"]))

    bs = BranchStatus(css[-1],
                      "test:my-branch",
                      "https://github.com/pulls/1",
                      {"commits": css, "files": None})
    session.add(bs)
    session.commit()

    assert_that(css[0].is_pending())
    assert_that(css[1].is_pending())
    assert_that(bs.is_pending())

    httpretty.enable()
    pull_request(bs.id,
                 "https://api.github.com/pulls/1",
                 "http://kwalitee.invenio-software.org/status/2",
                 {"repository": repository.id})
    httpretty.disable()

    latest_requests = httpretty.HTTPretty.latest_requests
    # 7x GET pull, .kwalitee.yml, issue, commits, files, spam/eggs.py,
    # spam/herp.html
    # 5x POST comments (1 message + 2 files), status
    # 1x PUT labels
    assert_that(len(latest_requests), equal_to(12), "7x GET + 4x POST + 1 PUT")

    expected_requests = [
        "",
        "",
        "",
        "missing component name",  # "signature is missing",
        "",
        "",
        "",
        "F821 undefined name",
        "L101 copyright is missing",
        "/status/2",
        "",
        "in_review"
    ]
    for expected, request in zip(expected_requests, latest_requests):
        assert_that(str(request.body), contains_string(expected))

    body = json.loads(latest_requests[-3].body)
    assert_that(latest_requests[-3].headers["authorization"],
                equal_to("token {0}".format(owner.token)))
    assert_that(body["state"], equal_to("error"))

    cs = CommitStatus.query.filter_by(repository_id=repository.id).all()

    assert_that(cs, has_length(2))
    assert_that(cs[0].content["message"],
                has_item("1: M110 missing component name"))
    assert_that(cs[1].content["message"],
                has_item("1: M100 needs more reviewers"))

    bs = BranchStatus.query.filter_by(commit_id=cs[1].id,
                                      name="test:my-branch").first()

    assert_that(bs)
    assert_that(bs.content["commits"], has_items("1", "2"))
    assert_that(bs.errors, equal_to(12))
    assert_that(
        bs.content["files"]["spam/eggs.py"]["errors"],
        has_item("2:3: E111 indentation is not a multiple of four"))

def get_pull_requests(app, owner, repository, session):
    """Task pull_request /pulls/1 that already exists."""
    httpretty.reset()
    cs1 = CommitStatus(repository,
                       "1",
                       "https://github.com/pulls/1",
                       {"message": [], "files": {}})
    cs2 = CommitStatus(repository,
                       "2",
                       "https://github.com/pulls/2",
                       {"message": [], "files": {}})
    session.add(cs1)
    session.add(cs2)
    session.commit()

    bs = BranchStatus(cs2,
                      "test:my-branch",
                      "https://github.com/pulls/1",
                      {"commits": [cs1, cs2], "files": {}})
    session.add(bs)
    session.commit()
    assert_that(bs.is_pending(), equal_to(False))

    httpretty.enable()
    pull_request(bs.id,
                 "https://api.github.com/pulls/1",
                 "http://kwalitee.invenio-software.org/status/2",
                 {"ACCESS_TOKEN": "deadbeef"})
    httpretty.disable()

    latest_requests = httpretty.HTTPretty.latest_requests
    assert_that(len(latest_requests), equal_to(0),
                "No requests are expected")