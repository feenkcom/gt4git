Class {
	#name : #GtGitDefinitionsListEditor,
	#superclass : #GtGitDefinitionsDropdownEditor,
	#instVars : [
		'elements',
		'completionStencil',
		'addSelector',
		'removeSelector',
		'spawnOn'
	],
	#category : #'GToolkit4Git-UI - Element'
}

{ #category : #accessing }
GtGitDefinitionsListEditor >> addSelector: aSelector [
	addSelector := aSelector
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> completionStencil: aStencil [
	completionStencil := aStencil
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> create [

	| aDefinition anOwner theInitialNames addAction removeAction renameAction aTagger |
	theInitialNames := self getValue.

	addAction := [ :aNewTag | 
	             aNewTag name ifNotEmpty: [ 
		             repository
			             perform: addSelector
			             withArguments: { aNewTag name } ] ].

	removeAction := [ :aTag | 
	                repository
		                perform: removeSelector
		                withArguments: { aTag name } ].

	aTagger := BrTagger new
		           aptitude: (BrGlamorousTaggerEditableDropdownAptitude new
				            margin: self margin;
				            content: contentBlock;
				            tagLabel: [ :aTaggerTag | 
					            | aLabel |
					            aLabel := BrEditableLabel new
						                      text: aTaggerTag name;
						                      aptitude:
							                      (BrGlamorousEditableLabelAptitude new
								                       glamorousCodeFont;
								                       defaultForeground: Color black;
								                       fontSize: 10).
					            spawnOn ifNotNil: [ 
						            aLabel
							            whenKey: BlKeyCombination primaryB
							            labelDo: [ :aShortcutEvent :aShortcut | 
								            spawnOn value: aTagger phlow value: aTaggerTag name ] ].
					            aLabel ]);
		           namedTags: theInitialNames;
		           when: BrTaggerAddTagRequest
		           do: [ :aRequest | addAction value: aRequest tag ];
		           when: BrTaggerRemoveTagRequest
		           do: [ :aRequest | removeAction value: aRequest tag ];
		           when: BrTaggerRenameTagRequest do: [ :aRequest | 
		           renameAction value: aRequest tag value: aRequest newName ].

	^ aTagger
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> elements: aCollection [
	elements := aCollection
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> getValue [
	^ repository perform: getSelector withArguments: {}.
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> removeSelector: aSelector [
	removeSelector := aSelector
]

{ #category : #accessing }
GtGitDefinitionsListEditor >> spawnOn: aBlock [
	spawnOn := aBlock
]
