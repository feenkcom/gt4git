Class {
	#name : #GtGitDefinitionsStaticDropdownEditor,
	#superclass : #GtGitDefinitionsDropdownEditor,
	#instVars : [
		'options',
		'action'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsStaticDropdownEditor >> action: aBlock [
	action := aBlock
]

{ #category : #accessing }
GtGitDefinitionsStaticDropdownEditor >> create [

	^ self createWithContent: [ 
		  BrSimpleList new
			  itemStencil: [ 
				  BrButton new
					  hMatchParent;
					  aptitude: BrGlamorousLabelAptitude new glamorousRegularFont
						  + (BrInteractiveCommonAptitude new
								   default: [ :f | f background: Color transparent ];
								   hovered: [ :f | 
									   f background: self theme button defaultBorderColor ]);
					  yourself ];
			  itemDataBinder: [ :aButton :eachTag | 
				  aButton
					  label: eachTag asString;
					  action: [ :aButtonElement | 
						  action value: eachTag.
						  aButtonElement fireEvent: BrDropdownHideWish new ] ];
			  items: options;
			  hFitContent;
			  vFitContent ]
]

{ #category : #accessing }
GtGitDefinitionsStaticDropdownEditor >> options: aCollectionOfStrings [
	options := aCollectionOfStrings
]
