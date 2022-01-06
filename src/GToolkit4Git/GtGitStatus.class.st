Class {
	#name : #GtGitStatus,
	#superclass : #Object,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatus >> asElement [

	| element |
	element := BlElement new
		           addAptitude:
			           (BrGlamorousWithLabelTooltipAptitude new text:
					            self label);
		           margin: (BlInsets left: 10);
		           layout: BlLinearLayout horizontal alignCenter;
		           constraintsDo: [ :c | 
			           c horizontal fitContent.
			           c vertical matchParent ].
	element addChild: self icon asElement asScalableElement.
	^ element
]

{ #category : #accessing }
GtGitStatus >> bareIcon [
	^ self icon
]

{ #category : #accessing }
GtGitStatus >> icon [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitStatus >> label [
	^ self subclassResponsibility
]
