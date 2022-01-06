Class {
	#name : #GtGitStatus,
	#superclass : #Object,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatus >> asElement [

	^ self icon asElement
		  aptitude: (BrGlamorousWithLabelTooltipAptitude new text: self label)
]

{ #category : #accessing }
GtGitStatus >> icon [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitStatus >> label [
	^ self subclassResponsibility
]
