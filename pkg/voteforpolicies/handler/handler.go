package handler

import "github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"

type Handler struct {
	storage       result.Storage
	renderer      *result.Renderer
	origin        *result.S3
	originAddress string
}

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
