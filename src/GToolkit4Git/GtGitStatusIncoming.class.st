Class {
	#name : #GtGitStatusIncoming,
	#superclass : #GtGitStatusWithCount,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatusIncoming >> icon [
	^ self iconWithCount: BrGlamorousVectorIcons down
]

{ #category : #accessing }
GtGitStatusIncoming >> label [
	^ count asString, ' incoming changes'
]
