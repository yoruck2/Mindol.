# <img src="https://github.com/user-attachments/assets/d104f54f-8422-428b-87e3-070590d37ca4" width="100"/> 마음돌.봄
그날의 감정을 대신 표현해주는 돌 캐릭터와 함께 기록하고 쌓을 수 있는 감정일기 앱
"소중한 기억들을 돌에 새겨 차곡차곡 쌓아보세요."
>**개발환경**<br><br>
![Static Badge](https://img.shields.io/badge/Xcode-15.4-blue) ![Static Badge](https://img.shields.io/badge/Swift-5.10-orange) ![Static Badge](https://img.shields.io/badge/iOS-16.0%2B-pink)
><br>
기간: 2024.09.10 ~ 2024.10.02 (약 4주)<br>
인원: 1명
## 📷 ScreenShot

|메인화면|달력화면|일기상세|일기작성|일기열람|
|:-:|:-:|:-:|:-:|:-:|
|<img src="https://github.com/user-attachments/assets/56e0d0f2-4b81-40d0-81d5-ba4b4c245f79" width="150"/>|<img src="https://github.com/user-attachments/assets/ca81512e-3ce3-4632-99da-b680cf98de19" width="150"/>|<img src="https://github.com/user-attachments/assets/292ff455-5c5d-4938-9c0a-85c029d8aab9" width="150"/>|<img src="https://github.com/user-attachments/assets/d45cfc7a-6574-47fe-ab36-4e42f04da8f3" width="150" width="150"/>|


## 📌 주요기능
- **일기 작성/수정/삭제**: 일기를 위한 기본적인 CRUD를 할 수 있습니다.
- **돌 쌓기**: 유저가 작성한 작성한 일기의 감정 돌 캐릭터가 메인 화면에 쌓입니다. 쌓인 돌들은 디바이스의 움직임에 맞춰 굴러갑니다.
- **달력 기능**: 달력을 통해 한눈에 일기현황을 파악할 수 있으며 일기를 열람하거나 새 일기를 작성할 수 있습니다.
- **월간/연간 리스트로 일기 열람**
    - 리스트 형태로 일기를 열람하고 지정한 연/월로 조회할 수 있습니다.
    - 일기검색기능(예정)
#### 예정된 업데이트
- 일기 검색기능
- 사진 추가기능
- 음성 녹음기능

## 🧰 기술스택
| 분야               | 기술 스택                                  |
|--------------------|-------------------------------------------|
| 🎨 UI              | `SwiftUI`<br>                            |
| 📦 데이터베이스       | `RealmSwift`<br>`+ Repository 패턴`        |
| 🎸 기타             | `SpriteKit`<br>`CoreMotion`<br>             |

## 🛠️ 주요 기술 상세


- `SpriteKit` + `CoreMotion`
    - 해당하는 달의 일기를 각각의 node로 생성해 physicsBody에 현실과 유사한 물리법칙을 적용하고 CoreMotion 을 활용해 디바이스 움직임에 따라 node가 움직이도록 구현

- `SwiftUI` + `RealmSwift`
    - @ObservedResults와 @ObservedRealmObject 프로퍼티 래퍼를 사용해 데이터가 변경될 때마다 자동으로 UI가 업데이트되도록 구현
    - Repository 패턴으로 데이터베이스 작업을 하나의 클래스로 모아 관리
