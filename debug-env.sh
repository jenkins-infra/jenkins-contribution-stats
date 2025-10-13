#!/usr/bin/env bash

echo "=== Debug Environment ==="
echo "Current user: $(id)"
echo "HOME: $HOME"
echo "PATH: $PATH"
echo ""

echo "=== Checking Homebrew directory permissions ==="
ls -la /home/linuxbrew/.linuxbrew/bin/ | head -20
echo ""

echo "=== Checking if tools exist ==="
echo "jenkins-contribution-aggregator: $(ls -la /home/linuxbrew/.linuxbrew/bin/jenkins-contribution-aggregator 2>&1)"
echo "jenkins-contribution-extractor: $(ls -la /home/linuxbrew/.linuxbrew/bin/jenkins-contribution-extractor 2>&1)"
echo ""

echo "=== Testing which command ==="
which jenkins-contribution-aggregator 2>&1 || echo "which failed with exit code $?"
which jenkins-contribution-extractor 2>&1 || echo "which failed with exit code $?"
echo ""

echo "=== Testing command -v ==="
command -v jenkins-contribution-aggregator 2>&1 || echo "command -v failed with exit code $?"
command -v jenkins-contribution-extractor 2>&1 || echo "command -v failed with exit code $?"
echo ""

echo "=== Testing direct execution ==="
/home/linuxbrew/.linuxbrew/bin/jenkins-contribution-aggregator version 2>&1 || echo "Direct execution failed with exit code $?"
/home/linuxbrew/.linuxbrew/bin/jenkins-contribution-extractor version 2>&1 || echo "Direct execution failed with exit code $?"
