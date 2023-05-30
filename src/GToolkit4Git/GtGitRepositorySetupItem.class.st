Class {
	#name : #GtGitRepositorySetupItem,
	#superclass : #Object,
	#instVars : [
		'repository'
	],
	#category : #'GToolkit4Git-Model'
}

{ #category : #accessing }
GtGitRepositorySetupItem class >> priority [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepositorySetupItem >> actionButtonLabelled: buttonText withDropdownContent: dropdownContent [
	| aButton aDropdown |
	aButton := BrButton new
			aptitude: BrGlamorousButtonWithLabelAptitude
					+ (BrGlamorousWithDropdownAptitude
							handle: [ aDropdown := BrButton new
										aptitude: BrGlamorousButtonWithLabelAptitude - BrGlamorousButtonExteriorAptitude;
										label: buttonText ]
							content: [ dropdownContent cull: aButton ]);
			label: buttonText.
	^ aButton
]

{ #category : #accessing }
GtGitRepositorySetupItem >> buildActionsIn: aStream [ 
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepositorySetupItem >> buildCheckbox [
	^ BrHorizontalPane new
		width: 56;
		padding: (BlInsets top: 6);
		addChild: (self disabledCheckBoxChecked: self isExecuted)
]

{ #category : #accessing }
GtGitRepositorySetupItem >> buildContent [
	| aStream |
	aStream := BlTextStream new.
	aStream next putAll: self message.
	self buildActionsIn: aStream.
	^ BrEditor new
		padding: BlInsets empty;
		text: aStream contents;
		aptitude: BrGlamorousRegularEditorAptitude
]

{ #category : #accessing }
GtGitRepositorySetupItem >> disabledCheckBoxChecked: aBoolean [
	^ BrCheckbox new
		aptitude: BrGlamorousCheckboxAptitude
				+ (BrCheckboxAptitude new
						hovered: [ :aStyle | 
							aStyle
								border: (BlBorder paint: BrTheme default button defaultBorderColor width: 1) ]);
		margin: (BlInsets left: 14);
		disable;
		checked: aBoolean
]

{ #category : #accessing }
GtGitRepositorySetupItem >> isExecuted [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepositorySetupItem >> isRequired [
	^ true
]

{ #category : #accessing }
GtGitRepositorySetupItem >> message [
	^ self subclassResponsibility
]

{ #category : #accessing }
GtGitRepositorySetupItem >> repository [
	^ repository
]

{ #category : #accessing }
GtGitRepositorySetupItem >> repository: anObject [
	repository := anObject
]
