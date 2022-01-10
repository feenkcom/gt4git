Class {
	#name : #GtGitDefinitionsDropdownEditor,
	#superclass : #GtGitDefinitionsEditor,
	#instVars : [
		'contentBlock',
		'value'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> contentBlock: aBlock [
	contentBlock := aBlock
]

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> create [
	^ self createWithContent: contentBlock
]

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> createWithContent: aBlock [

	| aDropdown theInitialName |
	theInitialName := self getValue.

	aDropdown := BrLabel new
		             aptitude:
			             lookStencil create + (BrGlamorousWithDropdownAptitude
					              handle: [ 
						              BrLabel new
							              text: theInitialName;
							              margin: self margin - (BlInsets bottom: 3);
							              geometry:
								              (BlRoundedRectangleGeometry cornerRadius: 4);
							              layout: BlLinearLayout horizontal alignCenter;
							              padding: (BlInsets top: 3 bottom: 3);
							              aptitude:
								              lookStencil create
								              - BrGlamorousButtonExteriorAptitude ]
					              content: [aBlock cull: aDropdown]);
		             margin: self margin;
		             text: theInitialName;
		             geometry: (BlRoundedRectangleGeometry cornerRadius: 4);
		             layout: BlLinearLayout horizontal alignCenter;
		             padding: (BlInsets top: 3 bottom: 3);
		             background:
		             BrGlamorousColors disabledButtonBackgroundColor.

	^ aDropdown
]

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> getValue [
	^ value
]

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> initialize [

	super initialize.

	lookStencil := [ 
	               BrGlamorousLabelAptitude new
		               glamorousCodeFont;
		               fontSize: 10 ] asStencil
]

{ #category : #accessing }
GtGitDefinitionsDropdownEditor >> value: aValue [
	value := aValue
]
