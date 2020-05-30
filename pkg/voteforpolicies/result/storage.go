package result

type Storage interface {
	Save(*Result) error
	// GetByID(string) (*Result, error)
	// GetAll() ([]*Result, error)
}
