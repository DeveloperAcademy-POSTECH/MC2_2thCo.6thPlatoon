# 🎯 MC2 2중대 6소대

# 📚 Project Convention

## 📢 공지사항

1. Github webhook이 연동되었습니다.
    - 여러분의 Push, Pull Request, Issue 등의 작업 내용이 github에 접수되면 곧바로 discord의 깃허브 채널에서 확인할 수 있습니다.
2. 작업을 위한 뼈대 파일이 main 브랜치에 추가되었습니다.
    - 작업을 하기 위해, 각자의 작업 폴더에 git clone 명령어를 통해 레포지토리를 복사하신 후 사용하실 수 있습니다.
    - 물론 그 전에 Issue 와 Branch 사용법을 익혀 봅시다.

## 🎫 Issue 사용법

- 이슈는 현재 Template이 있습니다. Github 상단의 Issue 탭에서 생성하거나 삭제, 수정이 가능합니다.
- 각 이슈는 번호를 갖고 있습니다. 이 번호를 "이슈 넘버"라고 합니다.
- 하나의 이슈는 "하나의 큰 작업"을 의미합니다. 2중대 6소대에서 의미하는 하나의 큰 작업은 대략 200 ~ 500줄 정도의 수정을 의미합니다.
- Assignees에는 본인을 태그하며, Label은 약식으로 Feat, Bug 중 하나를 골라서 진행합니다.

### ✍️ 이슈 작성 예시

```markdown
제목: [Feat] MainRecordView에서 말하는 사람을 바꾸기 위한 슬라이드를 구현합니다.

본문:
📝 작업 목적
MainRecordView에서 말하는 사람을 바꿀 수 있도록 슬라이드 구현

🛠️ Tasks
- [ ] 할일 1
- [ ] 할일 2
    - [ ] 할일 2의 서브 태스크
```

### 🌿 Branch 사용법
- Branch: dev를 제외한 모든 브랜치는 하나의 혹은 2개 이상의 Issue에 의해 생성되어야 합니다.
- 각 작업 사항을 작성한 Issue에서 branch를 분기합니다.

## 🌱 브랜치 생성 예시
```markdown
Feat/#325-Record-Implement-Slider
```

## 📝 Commit Convention
- 간단하게 머릿말은 4개정도 쓰겠습니다.
```markdown
[Feat/#이슈번호] 구현한 거
[Add/#이슈번호] 추가한 거
[Remove/#이슈번호] "파일" 지운 거
[Chore/#이슈번호] 기타
```
💡 pbxproj 파일 꼭꼭 맨 마지막에 커밋
