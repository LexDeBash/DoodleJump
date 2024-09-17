//
//  Platform.swift
//  DJTestApp
//
//  Created by Alexey Efimov on 14.09.2024.
//

enum PlatformType {
    case staticPlatform // Статичная платформа
    case movingPlatform // Движущаяся платформа
    case disappearingPlatform // Исчезающая платформа
}

struct Platform {
    var positionY: Double // Позиция по оси Y
    var positionX: Double // Позиция по оси X (важно для движущихся платформ)
    var type: PlatformType // Тип платформы
    var isVisible = true // Для исчезающих платформ
}
