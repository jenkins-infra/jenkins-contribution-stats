#!/usr/bin/env bash
set -e

jenkins-get-commenters data/submissions-2023-08.csv -a
jenkins-get-commenters data/submissions-2023-07.csv -a
jenkins-get-commenters data/submissions-2023-06.csv -a
jenkins-get-commenters data/submissions-2023-05.csv -a
jenkins-get-commenters data/submissions-2023-04.csv -a
jenkins-get-commenters data/submissions-2023-03.csv -a
jenkins-get-commenters data/submissions-2023-02.csv -a
jenkins-get-commenters data/submissions-2023-01.csv -a
jenkins-get-commenters data/submissions-2022-12.csv -a
jenkins-get-commenters data/submissions-2022-11.csv -a
jenkins-get-commenters data/submissions-2022-10.csv -a
jenkins-get-commenters data/submissions-2022-09.csv -a
