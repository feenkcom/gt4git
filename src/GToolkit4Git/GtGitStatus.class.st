Class {
	#name : #GtGitStatus,
	#superclass : #Object,
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitStatus class >> color [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitStatus >> asElement [

	| element |
	element := BlElement new
		           addAptitude:
			           (BrGlamorousWithExplicitTooltipAptitude text:
					            self label);
		           margin: (BlInsets right: 10);
		           layout: BlLinearLayout horizontal alignCenter;
		           background: self class color;
		           geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		           constraintsDo: [ :c | 
			           c horizontal fitContent.
			           c vertical matchParent ].
	element addChild: self icon asElement asScalableElement.
	^ element
]

{ #category : #accessing }
GtGitStatus >> asLabelElement [
	
	| element |
	element := BlElement new
		           margin: (BlInsets right: 10);
		           layout: BlLinearLayout horizontal alignCenter;
		           background: self class color;
		           geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		           constraintsDo: [ :c | 
			           c horizontal fitContent.
			           c vertical matchParent ].
	element addChild: self bareIcon asElement asScalableElement.
	element addChild: (BrLabel new aptitude: BrGlamorousLabelAptitude; text: self label).
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
