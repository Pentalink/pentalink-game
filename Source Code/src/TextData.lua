HELP_DATA = {
    ['title'] = 'How to play',
    ['headers'] = {"Objective", "Rulebook", "Point system", "Streaks", "Streak points"},
    ['info'] = {
        ["Objective"] = {
            "The aim of the game is to have more points than your opponent when no more legal moves are possible."
        },
        ["Rulebook"] = {
            "It is a turn-based game",
            "Each turn consists of joining a vertex of a line to a vertex of another line",
            "The drawn line cannot intersect another line",
            "The game ends when no legal moves are possible, and the points of each player are calculated",
            "A polygon may not contain any other shapes or lines inside of it.",
            "At the end of the game, the player who has the maximum total area of pentagons receives an additional ".. tostring(MOST_AREA_POINTS) .. " points. If the area is tied between two players, both players receive ".. tostring(TIED_AREA_POINTS).. " additional points.",
        },
        ["Point system"] = {
            "Pentagon: " .. tostring(POLYGON_POINTS[5]) .. " points",
            "Heptagon: " .. tostring(POLYGON_POINTS[7]) .. " points",
            "Hexagon: " .. tostring(POLYGON_POINTS[6]) .. " points",
            "Quadrilateral: " .. tostring(POLYGON_POINTS[4]) .. " points",
            "Triangle: " .. tostring(POLYGON_POINTS[3]) .. " points",
        },
        ["Streaks"] = {
            "'Streaks' are another way of earning points.",
            "A streak is when two or more pentagons are made consecutively.",
            "The points are given to the player who played just before the first pentagon in the streak was made.",
        },
        ["Streak points"] = {
            "Two pentagon streak: " .. tostring(STREAK_POINTS[2]) .. " points",
            "Three pentagon streak: " .. tostring(STREAK_POINTS[3]) .. " points",
            "Four pentagon streak: " .. tostring(STREAK_POINTS[4]) .. " points",
            "Five pentagon streak: " .. tostring(STREAK_POINTS[5]) .. " points",
        }
    }
}

CREDITS_DATA = {
    ['title'] = {"Credits"},
    ['headers'] = {"Original Idea", "Lead Programmer", "Programming team", "Game Engineers"},
    ['info'] = {
        ["Original Idea"] = {"Stavan Jain"},
        ["Lead Programmer"] = {"Vishnu Nittoor"},
        ["Programming team"] = {"Aryaman Dwivedi"},
        ["Game Engineers"] = {"Stavan Jain", "Rohan Subramaniam"}
    },
}
