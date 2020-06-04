package result

// Result represents a result
type Result struct {
	ID       string             `json:"id"`
	Party    map[Party]uint     `json:"party"`
	Category map[Category]Party `json:"category"`
}

// Party represents a party
type Party string

// Category represents a survey category
type Category string
