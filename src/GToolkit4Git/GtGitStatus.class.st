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
		           margin: (BlInsets right: 10);
		           layout: BlLinearLayout horizontal alignCenter;
		           background: self color;
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
GtGitStatus >> color [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitStatus >> icon [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitStatus >> label [
	^ self subclassResponsibility
]
