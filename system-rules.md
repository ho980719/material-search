
# 📦 Prompt Rules: 자재 위치 관리 앱 (Flutter + SQLite)

## 🧭 프로젝트 개요
이 앱은 Flutter 기반의 자재 위치 관리 앱입니다.  
사용자는 자재 정보를 등록, 수정, 삭제, 검색할 수 있습니다.  
자재는 `zone`이라는 단일 위치 단위와 연결됩니다.

## 🛠 기술 스택
- **Flutter (Dart)**
- **SQLite** (`sqflite` 패키지 사용)
- **Android 전용 앱 개발 / 태블릿 활용 예정**

---

## 🧱 데이터베이스 설계 (간소화 버전)

### ✅ zone 테이블
```sql
CREATE TABLE IF NOT EXISTS zone (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  memo TEXT
);
```

### ✅ material 테이블
```sql
CREATE TABLE IF NOT EXISTS material (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL,
  zone_id INTEGER NOT NULL,
  FOREIGN KEY (zone_id) REFERENCES zone(id)
);
```

### ✅ 자재 + 위치 조회 쿼리 예시
```sql
SELECT
  m.id,
  m.name,
  m.quantity,
  z.name AS zone_name,
  z.memo
FROM material m
JOIN zone z ON m.zone_id = z.id
ORDER BY m.id DESC;
```

---

## 🔑 주요 기능 목록

### 1. 자재 등록
- 이름(name), 수량(quantity), zone 선택(zone_id)

### 2. 자재 검색
- 자재 이름 또는 zone 이름으로 검색 가능

### 3. 자재 수정 / 삭제
- ID 기준으로 수정/삭제 가능

### 4. 전체 목록 보기
- 자재 목록과 zone 이름 함께 표시

---

## 🎨 개발 스타일 가이드

- `StatefulWidget` 또는 `Provider`, `Riverpod` 등 상태관리 선택적 사용
- DB는 `sqflite` 기반, 별도 DB 서비스 클래스로 분리
- Android UI 최적화
- 간단한 UI로 실용성 우선
- 예외 및 콘솔 로그 출력 포함

---