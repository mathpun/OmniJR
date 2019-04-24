load omniJrRaw

%Clean Drawings
for alphabetIndex = 1:length(drawings)
	alphabet = drawings{alphabetIndex};

	for letterIndex = 1:length(alphabet)
		letter = alphabet{letterIndex};

		for drawingIndex = 1:length(letter)
			d = matrix2CellVector(letter{drawingIndex});
			drawings{alphabetIndex}{letterIndex}{drawingIndex} = d;

			for strokeIndex = 1:length(d)
				stroke = d{strokeIndex};
				stroke = squeeze(stroke);
				drawings{alphabetIndex}{letterIndex}{drawingIndex}{strokeIndex} = stroke;
            end
        end
    end
    
end


%Clean Images
for alphabetIndex = 1:length(images)
	alphabet = matrix2CellVector(images{alphabetIndex});
	images{alphabetIndex} = alphabet;

	for letterIndex = 1:length(alphabet)
		letter = matrix2CellVector(alphabet{letterIndex});
		images{alphabetIndex}{letterIndex} = letter;

		for drawingIndex = 1:length(letter)
			d = squeeze(letter{drawingIndex});
			images{alphabetIndex}{letterIndex}{drawingIndex} = d;
		end
	end
end

        
%Clean Timings
for alphabetIndex = 1:length(timing)
	alphabet = timing{alphabetIndex};

	for letterIndex = 1:length(alphabet)
		letter = alphabet{letterIndex};

		for drawingIndex = 1:length(letter)
			d = matrix2CellVector(letter{drawingIndex});
            %disp(class(d));
			timing{alphabetIndex}{letterIndex}{drawingIndex} = d;

			for strokeIndex = 1:length(d)
				stroke = d{strokeIndex};
				stroke = squeeze(stroke);
                stroke = reshape(stroke, [1, length(stroke)]);
				timing{alphabetIndex}{letterIndex}{drawingIndex}{strokeIndex} = stroke;
            end
        end
    end
    
end

save omniJr drawings timing images names offsets







	