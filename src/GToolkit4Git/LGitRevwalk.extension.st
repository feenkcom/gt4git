Extension { #name : #LGitRevwalk }

{ #category : #'*GToolkit4Git' }
LGitRevwalk >> stream [
	^ AsyncIteratorStream forIterator: self
]
