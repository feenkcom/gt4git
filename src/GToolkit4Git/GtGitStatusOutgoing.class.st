Class {
	#name : #GtGitStatusOutgoing,
	#superclass : #GtGitStatusWithCount,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusOutgoing >> icon [
	^ self iconWithCount: BrGlamorousVectorIcons up
]

{ #category : #accessing }
GtGitStatusOutgoing >> label [
	^ count asString, ' outgoing changes'
]
