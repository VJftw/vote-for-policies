package handler

import (
	"fmt"
	"log"
	"net/http"
	"strings"

	"github.com/VJftw/vote-for-policies/pkg/voteforpolicies/result"
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

// PostResults handles the POST of results request
func (h *Handler) PostResults(c *gin.Context) {
	err := c.Request.ParseForm()
	if err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	id, err := uuid.NewRandom()
	if err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	res := &result.Result{
		ID:       id.String(),
		Party:    map[result.Party]uint{},
		Category: map[result.Category]result.Party{},
	}

	for k, v := range c.Request.PostForm {
		category := result.Category(k)
		party := result.Party(v[0])

		res.Category[category] = party

		if _, ok := res.Party[party]; !ok {
			res.Party[party] = 0
		}
		res.Party[party]++
	}

	// persist async
	waitPersist := make(chan struct{})
	go func() {
		if err := h.storage.Save(res); err != nil {
			log.Println(err)
		}
		close(waitPersist)
	}

	// render
	bodyStr, err := h.renderer.RenderResult(res)
	if err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	// push to s3
	body := strings.NewReader(bodyStr)
	keyPath, err := h.origin.Save(fmt.Sprintf("%s/index.html", res.ID), body)
	if err != nil {
		log.Println(err)
		c.JSON(500, err)
		return
	}

	// redirect
	c.Redirect(http.StatusSeeOther, fmt.Sprintf("%s%s", h.originAddress, keyPath))

	<-waitPersist
}

