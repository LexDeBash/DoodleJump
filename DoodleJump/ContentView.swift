//
//  ContentView.swift
//  DoodleJump
//
//  Created by Alexey Efimov on 04.09.2024.
//

import SwiftUI

// Состояние игры
enum GameState {
    case ready, active, stopped
}

struct ContentView: View {
    // Позиция дудлера на игровом поле
    @State private var doodlerYPosition = 0.0
    @State private var doodlerXPosition = 0.0 // Начальная позиция по оси X
    
    // Скорость дудлера по оси Y
    @State private var doodlerYVelocity = 0.0
    @State private var doodlerXVelocity = 0.0 // Начальная скорость дудлера по оси X
    
    @State private var doodlerXAcceleration = 0.0 // Ускорение по оси X
    
    // Платформы: массив с позициями по Y
    @State private var platforms: [Platform] = []
    
    @State private var gameState: GameState = .ready
    @State private var score = 0
    @AppStorage(wrappedValue: 0, "highScore") private var highScore: Int
    
    // Используем настройки игры
    private let settings = GameSettings.defaultSettings
    
    var body: some View {
        // Дудлер — пока это просто окружность
        GeometryReader { geometry in
            let width = geometry.size.width
            
            ZStack {
                // Отображение счета в левом верхнем углу
                Text(score.formatted())
                    .font(.title)
                    .padding()
                    .foregroundColor(.black)
                    .position(x: 60, y: 60) // Устанавливаем позицию в левом верхнем углу

                
                // Отображаем платформы
                ForEach(platforms.indices, id: \.self) { index in
                    let platform = platforms[index]
                    
                    if platform.isVisible {
                        PlatformView(width: settings.platformWidth, height: settings.platformHeight)
                            .position(x: platform.positionX, y: platform.positionY)
                    }
                }
                
                DoodlerView(height: settings.doodlerHeight)
                    .position(x: doodlerXPosition, y: doodlerYPosition)
                
                if gameState == .ready {
                    Button(action: playButtonAction) {
                        Image(systemName: "play.fill")
                            .scaleEffect(x: 3.5, y: 3.5)
                    }
                    .foregroundColor(.blue)
                }

                if gameState == .stopped {
                    ResultView(score: score, highScore: highScore) {
                        resetGame(geometry: geometry)
                    }
                }
            }
            .background(.blue.opacity(0.1)) // Простой фон
            .ignoresSafeArea() // Убираем границы
            .gesture(
                DragGesture()
                    .onChanged { value in
                        // Изменяем ускорение в зависимости от направления жеста
                        if value.translation.width > 0 {
                            // Ускорение вправо
                            doodlerXAcceleration = settings.accelerationRate
                        } else if value.translation.width < 0 {
                            // Ускорение влево
                            doodlerXAcceleration = -settings.accelerationRate
                        }
                    }
                    .onEnded { _ in
                        // Когда жест закончен, ускорение сбрасывается
                        doodlerXAcceleration = 0.0
                    }
            )
            .onAppear {
                // Сброс параметров игры на начальные установки
                resetGame(geometry: geometry)
                
                // Запускаем таймер для обновления позиции дудлера
                Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
                    guard gameState == .active else { return }
                    applyGravity(width: width)
                    limitFallToBottomEdge()
                    handleScrolling()
                    updatePlatforms(geometry: geometry)
                    applyHorizontalMovement(width: width)
                }
            }
        }
    }
}

// MARK: - Gravity and Movement
private extension ContentView {
    // Метод для применения гравитации
    func applyGravity(width: Double) {
        // Применяем гравитацию, только если дудлер не касается платформы
        if !isOnPlatform() {
            doodlerYVelocity += settings.gravity
        }
        doodlerYPosition += doodlerYVelocity
    }
    
    // Метод для ограничения падения ниже нижней границы экрана
    func limitFallToBottomEdge() {
        if doodlerYPosition > UIScreen.main.bounds.height + settings.doodlerHeight { // Если дудлер упал за экран
            doodlerYPosition = UIScreen.main.bounds.height + settings.doodlerHeight
            gameState = .stopped
        }
    }
    
    func applyHorizontalMovement(width: Double) {
        // Обновляем скорость дудлера с учетом ускорения
        doodlerXVelocity += doodlerXAcceleration
        
        // Ограничиваем скорость до максимальной
        doodlerXVelocity = min(max(doodlerXVelocity, -settings.maxVelocity), settings.maxVelocity)
        
        // Если ускорение отсутствует, постепенно замедляем дудлера (эффект трения)
        if doodlerXAcceleration == 0 {
            doodlerXVelocity *= settings.decelerationRate
        }

        // Обновляем позицию дудлера по оси X
        doodlerXPosition += doodlerXVelocity

        // Логика wraparound: если дудлер выходит за пределы экрана, переносим его на противоположную сторону
        if doodlerXPosition < -settings.doodlerHeight / 2 {
            doodlerXPosition = width + settings.doodlerHeight / 2
        } else if doodlerXPosition > width + settings.doodlerHeight / 2 {
            doodlerXPosition = -settings.doodlerHeight / 2
        }
    }
}

// MARK: - Platform Management
private extension ContentView {
    // Метод для проверки столкновений с платформами
    private func isOnPlatform() -> Bool {
        for index in platforms.indices {
            let platform = platforms[index]
            
            if doodlerYPosition + settings.doodlerHeight / 2 >= platform.positionY - settings.platformHeight / 2 &&
                doodlerYPosition + settings.doodlerHeight / 2 <= platform.positionY + settings.platformHeight / 2 &&
                doodlerXPosition >= platform.positionX - settings.platformWidth / 2 &&
                doodlerXPosition <= platform.positionX + settings.platformWidth / 2 &&
                doodlerYVelocity > 0 && platform.isVisible {
                
                // Для исчезающих платформ делаем их невидимыми после прыжка
                if platform.type == .disappearingPlatform {
                    platforms[index].isVisible = false
                }
                
                // Дудлер подпрыгивает
                doodlerYVelocity = settings.jumpVelocity
                return true
            }
        }
        return false
    }
    
    // Метод для обработки скроллинга платформ
    func handleScrolling() {
        // Скроллинг срабатывает только если дудлер поднимается
        if doodlerYVelocity < 0 && doodlerYPosition < settings.scrollThreshold {
            let offset = settings.scrollThreshold - doodlerYPosition
            doodlerYPosition = settings.scrollThreshold // Фиксируем дудлера на позиции
            
            // Опускаем платформы на величину offset
            for index in platforms.indices {
                platforms[index].positionY += offset
            }

            // Обновляем счёт при скроллинге
            updateScoreAfterScrolling(offset: offset)
        }
    }
    
    func updatePlatforms(geometry: GeometryProxy) {
        // Обновляем движущиеся платформы
        updateMovingPlatforms()

        // Удаляем платформы, которые вышли за нижний край экрана
        platforms.removeAll { $0.positionY > geometry.size.height + settings.platformHeight || !$0.isVisible }
        
        // Добавляем новые платформы, если их меньше 5
        while platforms.count < 5 {
            let newPlatformY = (platforms.min { $0.positionY < $1.positionY }?.positionY ?? geometry.size.height) - Double.random(in: 80...100)
            let newPlatformType: PlatformType = [.staticPlatform, .movingPlatform, .disappearingPlatform].randomElement()! // Случайный тип платформы
            platforms.append(Platform(positionY: newPlatformY, positionX: Double.random(in: 50...350), type: newPlatformType))
        }
    }
    
    func updateMovingPlatforms() {
        for index in platforms.indices {
            if platforms[index].type == .movingPlatform {
                // Двигаем платформу по оси X (влево и вправо)
                platforms[index].positionX += 2.0
                if platforms[index].positionX > 350 {
                    platforms[index].positionX = 50 // Ограничиваем движение в пределах экрана
                }
            }
        }
    }
}

// MARK: - Game State Management
private extension ContentView {
    // Действие по нажатию на кнопку Play
    func playButtonAction() {
        gameState = .active
    }
    
    // Действие по нажатию на кнопку Reset
    func resetGame(geometry: GeometryProxy) {
        doodlerYPosition = geometry.size.height * 2 / 3
        doodlerXPosition = geometry.size.width / 2 // Половина ширины
        
        doodlerYVelocity = 0
        doodlerXVelocity = 0
        doodlerXAcceleration = 0
        
        score = 0
        
        // Добавляем платформы, начиная с первой платформы под дудлером
        platforms = [
            Platform(
                positionY: doodlerYPosition + 50,
                positionX: geometry.size.width / 2,
                type: .staticPlatform
            ), // Платформа под дудлером
            Platform(
                positionY: doodlerYPosition - 90,
                positionX: geometry.size.width / 2,
                type: .staticPlatform
            ), // Платформа выше
            Platform(
                positionY: doodlerYPosition - 200,
                positionX: geometry.size.width / 2,
                type: .staticPlatform
            )  // Еще одна выше
        ]
        
        gameState = .ready
    }
}

// MARK: - Scoring
private extension ContentView {
    // Обновление счёта при скроллинге
    func updateScoreAfterScrolling(offset: Double) {
        // Если дудлер поднимается, увеличиваем счёт в зависимости от смещения
        score += Int(offset)
        
        // Обновление рекорда
        if score > highScore {
            highScore = score
        }
    }
}

#Preview {
    ContentView()
}
