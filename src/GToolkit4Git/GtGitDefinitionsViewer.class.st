Class {
	#name : #GtGitDefinitionsViewer,
	#superclass : #BrStencil,
	#instVars : [
		'margin',
		'lookStencil',
		'title'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsViewer >> aptitude: aStencil [
	lookStencil := aStencil asStencil
]

{ #category : #accessing }
GtGitDefinitionsViewer >> buildSectionLabel: aSectionName [
	
	^ BrLabel new
		aptitude: (BrGlamorousLabelAptitude new glamorousRegularFontAndSize foreground: Color gray; fontSize: 12);
		text: aSectionName, ':';
		margin: (BlInsets top: 5 right: 5);
		focusability: BlFocusability none;
		constraintsDo: [ :c | c grid horizontal alignLeft ]
]

{ #category : #accessing }
GtGitDefinitionsViewer >> initialize [
	super initialize.
	
	margin := BlInsets top: 3 left: 0 bottom: 3 right: 5.
	lookStencil := [ BrGlamorousEditableLabelAptitude new
		glamorousCodeFont;
		defaultForeground: Color black;
		fontSize: 10 ] asStencil.
]

{ #category : #accessing }
GtGitDefinitionsViewer >> margin [
	^ margin
]

{ #category : #accessing }
GtGitDefinitionsViewer >> margin: aMargin [
	margin := aMargin
]

{ #category : #accessing }
GtGitDefinitionsViewer >> title [
	^ title
]

{ #category : #accessing }
GtGitDefinitionsViewer >> title: anObject [
	title := anObject
]
