#!/bin/bash

# kk3june-skills 설치 스크립트

set -e

SKILLS_DIR="$HOME/.claude/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🚀 kk3june-skills 설치를 시작합니다..."

# .claude/skills 디렉토리 생성
if [ ! -d "$SKILLS_DIR" ]; then
    echo "📁 $SKILLS_DIR 디렉토리를 생성합니다..."
    mkdir -p "$SKILLS_DIR"
fi

# 스킬 복사
echo "📦 스킬을 복사합니다..."
cp -r "$SCRIPT_DIR/skills/"* "$SKILLS_DIR/"

# CLAUDE.md 복사 (스킬 자동 트리거 규칙)
echo "📋 CLAUDE.md를 복사합니다..."
cp "$SCRIPT_DIR/CLAUDE.md" "$HOME/.claude/CLAUDE.md"

echo ""
echo "✅ 설치가 완료되었습니다!"
echo ""
echo "설치된 스킬:"
echo "  - context-collector: 프로젝트 스택 탐지 및 스킬 라우팅"
echo "  - skill-manager: 스킬 생성/동기화 관리"
echo "  - impl-frontend-react: React/Vite 구현"
echo "  - refactoring: 코드 품질 개선"
echo ""
echo "📍 스킬 위치: $SKILLS_DIR"
echo "📍 트리거 규칙: $HOME/.claude/CLAUDE.md"
echo ""
echo "💡 사용법: Claude Code에서 기능 구현이나 리팩토링을 요청하세요."
