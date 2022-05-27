//
//  ContentView.swift
//  Now
//
//  Created by Guillaume Bisiaux on 27/05/2022.
//

import SwiftUI

enum LoadingState {
	case loading, loaded, error
}

struct ContentView: View {
	
	@State var profiles: [Profile] = []
	@State var state: LoadingState = .loading
	@State var currentIndex: Int = 0
	@State var action: CardAction = .hello
	
	var body: some View {
		content
			.animation(.spring(), value: state)
			.task {
				state = .loading
				guard let url = URL(string: "https://www.plugco.in/public/take_home_sample_profiles") else {
					print("Invalid URL")
					state = .error
					return
				}
				
				do {
					let (data, _) = try await URLSession.shared.data(from: url)
					if let decodedResponse = try? JSONDecoder().decode(Result.self, from: data) {
						profiles = decodedResponse.profiles
						print(profiles)
						state = .loaded
					} else {
						state = .error
					}
				} catch {
					state = .error
					print("Invalid data")
				}
			}
	}
	
	@ViewBuilder
    var content: some View {
		switch state {
			case .loading:
				ProgressView()
					.progressViewStyle(CircularProgressViewStyle())
			case .loaded:
				VStack {
					topView
					if currentIndex >= profiles.count {
						Text("No more profiles. :(")
							.frame(maxHeight: .infinity)
					} else {
						cardView
						bottomView
					}
				}
				.animation(.spring(), value: currentIndex)
				.frame(maxWidth: UIScreen.main.bounds.width)
			case .error:
				Text("Oops...")
		}
    }
	
	var controlView: some View {
		HStack {
			Button {
				currentIndex -= 1
			} label: {
				Text("Down")
			}.disabled(currentIndex == 0)
			Spacer()
			Button {
				currentIndex += 1
			} label: {
				Text("Up")
			}.disabled(currentIndex == profiles.count - 1)
		}.padding()
	}

	@ViewBuilder
	var cardView: some View {
			ZStack {
				ForEach(Array(profiles.enumerated().reversed()), id: \.offset) { index, profile in
					ProfileCard(
						profile: profile,
						index: index,
						currentIndex: $currentIndex,
						action: $action
					)
					.offset(y: defineOffset(index: index))
				}
			}
			.frame(maxHeight: .infinity)
	}

	var topView: some View {
		ZStack {
			HStack {
				Image(systemName: "dial.min.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: 22, height: 22)
				Spacer()
				Circle()
					.fill(Color(hex: "FE3C72"))
					.frame(width: 38, height: 38)
					.overlay {
						Text("4")
							.font(.subheadline).bold()
							.foregroundColor(.white)
					}
			}
			Text("Now")
				.font(.title).bold()
				.foregroundColor(Color(hex: "FE3C72"))
				.frame(maxWidth: .infinity)
		}
		.padding()
	}
	
	var bottomView: some View {
		HStack {
			Spacer()
			Button {
				action = .goodBye
				currentIndex += 1
			} label: {
			Circle()
				.fill(Color(hex: "FE3C72"))
				.frame(width: 69, height: 69)
				.overlay {
					Image(systemName: "xmark")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 22, height: 22)
						.foregroundColor(.white)
				}
			}
				
			Spacer()
			Button {
				action = .hello
				currentIndex += 1
			} label: {
			Circle()
				.fill(Color(hex: "4CD964"))
				.frame(width: 69, height: 69)
				.overlay {
					Image(systemName: "checkmark")
						.resizable()
						.aspectRatio(contentMode: .fit)
						.frame(width: 22, height: 22)
						.foregroundColor(.white)
				}
			}
			Spacer()
		}
	}
	
	private func defineOffset(index: Int) -> CGFloat {
		if index == currentIndex {
			return 0
		} else if index == currentIndex + 1 {
			return 10
		} else {
			return 20
		}
	}
}

extension Color {
	init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int: UInt64 = 0
		Scanner(string: hex).scanHexInt64(&int)
		let a, r, g, b: UInt64
		switch hex.count {
			case 3: // RGB (12-bit)
				(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
			case 6: // RGB (24-bit)
				(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
			case 8: // ARGB (32-bit)
				(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
			default:
				(a, r, g, b) = (1, 1, 1, 0)
		}
		
		self.init(
			.sRGB,
			red: Double(r) / 255,
			green: Double(g) / 255,
			blue:  Double(b) / 255,
			opacity: Double(a) / 255
		)
	}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct Result: Codable {
	let profiles: [Profile]
}

struct Profile: Codable {
	let id: Int
	let firstName: String
	let lastName: String
	let city: String
	let country: String
	let isMatch: Bool
	let photos: [String]
	
	private enum CodingKeys: String, CodingKey {
		case id, city, country, photos
		case firstName = "first_name"
		case lastName = "last_name"
		case isMatch = "is_match"
	}
	
}
