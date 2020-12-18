T castOrDefault<T>(dynamic value, T defaultValue) =>
    value is T ? value : defaultValue;
