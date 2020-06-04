package result

// Storage abstracts the different result persistences
type Storage interface {
	Save(*Result) error
	// GetByID(string) (*Result, error)
	// GetAll() ([]*Result, error)
}
