package result

type Result struct {
	ID       string             `json:"id"`
	Party    map[Party]uint     `json:"party"`
	Category map[Category]Party `json:"category"`
}

type Party string
type Category string
