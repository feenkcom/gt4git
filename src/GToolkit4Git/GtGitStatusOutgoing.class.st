Class {
	#name : #GtGitStatusOutgoing,
	#superclass : #GtGitStatusWithCount,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusOutgoing class >> color [
	^ BrGlamorousColors selectedListItemColor 
]

{ #category : #accessing }
GtGitStatusOutgoing >> bareIcon [
	^ BrGlamorousVectorIcons up
]

{ #category : #accessing }
GtGitStatusOutgoing >> label [
	^ count asString, ' outgoing ', self changesInflection
]
