package handler

import "github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"

type Handler struct {
	storage       result.Storage
	origin        *result.S3
	originAddress string
}

func New(
	storage result.Storage,
	origin *result.S3,
	originAddress string) *Handler {
	return &Handler{
		storage:       storage,
		origin:        origin,
		originAddress: originAddress,
	}
}
