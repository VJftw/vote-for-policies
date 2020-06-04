package handler

import "github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"

// Handler represents the HTTP handler
type Handler struct {
	storage       result.Storage
	renderer      *result.Renderer
	origin        *result.S3
	originAddress string
}

// New returns a new handler
func New(
	storage result.Storage,
	renderer *result.Renderer,
	origin *result.S3,
	originAddress string) *Handler {
	return &Handler{
		storage:       storage,
		renderer:      renderer,
		origin:        origin,
		originAddress: originAddress,
	}
}
